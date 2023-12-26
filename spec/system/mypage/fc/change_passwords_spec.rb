# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mypage::Fc::ChangePasswords', type: :system do
  let!(:fc_user) { FactoryBot.create(:fc_user, :activated) }
  let(:current_password) { fc_user.password }
  let(:new_password) { '#zH6eTaJbLuXjA1' }
  let(:sf_account) { FactoryBot.build_stubbed(:sf_account_fc) }
  let(:sf_contact) { FactoryBot.build_stubbed(:sf_contact, :fc) }

  include Warden::Test::Helpers

  before do
    allow_any_instance_of(Account).to receive(:to_sobject).and_return(sf_account)
    allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)

    sign_in(fc_user)
  end

  it do
    visit edit_mypage_fc_password_url

    fill_in 'fc_user[current_password]', with: current_password
    fill_in 'fc_user[password]', with: new_password
    fill_in 'fc_user[password_confirmation]', with: new_password
    perform_enqueued_jobs do
      click_on '保存する'
    end

    expect(page.response_headers).to include('Location' => mypage_fc_settings_path)
    fc_user.reload
    expect(fc_user).to be_valid_password(new_password)

    email = open_last_email_for(fc_user.email)
    expect(email).to have_subject('【みらいワークス】パスワード設定完了・登録者限定コミュニティ「みらコミュ」のご案内(FreeConsultant.jp)')
  end
end
