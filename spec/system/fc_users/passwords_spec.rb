# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'FcUsers::Passwords', type: :system do
  describe 'パスワード再設定後に二段階認証を要求されないこと' do
    let(:fc_user) { FactoryBot.create(:fc_user, :activated, :registration_completed) }
    let(:new_password) { '#zH6eTaJbLuXjA1' }
    let(:sf_contact) { FactoryBot.build_stubbed(:sf_contact, :fc) }
    let(:sf_account) { FactoryBot.build_stubbed(:sf_account_fc) }
    let(:sf_content_document) { FactoryBot.build(:sf_content_document) }

    before do
      allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
      allow_any_instance_of(Account).to receive(:to_sobject).and_return(sf_account)
      allow(Salesforce::ContentDocument).to receive(:find_by).and_return(sf_content_document)

      # NOTE: 一度二段階認証を通してログアウトしておく
      visit new_fc_user_session_path
      fill_in 'fc_user[email]', with: fc_user.email
      fill_in 'fc_user[password]', with: fc_user.password
      click_button '同意してログイン'

      visit mypage_fc_settings_path
      click_link 'ログアウト'
    end

    it do
      visit new_fc_user_password_path
      fill_in 'fc_user_email', with: fc_user.email
      perform_enqueued_jobs do
        click_button('メールを送信する')
      end

      open_email(fc_user.email)
      click_email_link_matching(/http/)

      fill_in 'fc_user[password]', with: new_password
      fill_in 'fc_user[password_confirmation]', with: new_password
      perform_enqueued_jobs do
        find('input[type="submit"]').click
      end

      email = open_last_email_for(fc_user.email)
      expect(email).to have_subject('【みらいワークス】パスワード設定完了・登録者限定コミュニティ「みらコミュ」のご案内(FreeConsultant.jp)')

      visit new_fc_user_session_path
      fill_in 'メールアドレス', with: fc_user.email
      fill_in 'パスワード', with: new_password
      click_on '同意してログイン'

      expect(page.current_url).to eq mypage_fc_root_url
    end
  end
end
