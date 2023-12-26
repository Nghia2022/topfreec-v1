# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClientUserMailer, type: :mailer do
  describe '#reset_password_instructions' do
    let(:reset_password_token) { 'dummy' }
    let(:sf_account_fc) { FactoryBot.build_stubbed(:sf_account_fc) }
    let(:client_user) { FactoryBot.build_stubbed(:client_user, :with_contact, reset_password_token:) }
    let(:email) { ClientUserMailer.reset_password_instructions(client_user, reset_password_token) }

    before do
      allow(client_user.contact).to receive(:to_sobject).and_return(sf_account_fc)
    end

    it do
      expect(email).to have_subject('パスワード設定用URLのご送付')
        .and have_body_text(sf_account_fc.LastName)
        .and have_body_text(sf_account_fc.FirstName)
        .and have_body_text(edit_client_user_password_url(@client_user, reset_password_token:))
        .and have_body_text(contact_ja_url)
    end
  end

  describe '#password_change' do
    let(:sf_account_fc) { FactoryBot.build_stubbed(:sf_account_fc) }
    let(:client_user) { FactoryBot.build_stubbed(:client_user, :with_contact) }
    let(:email) { ClientUserMailer.password_change(client_user) }

    before do
      allow(client_user.contact).to receive(:to_sobject).and_return(sf_account_fc)
    end

    it do
      expect(email).to have_subject('パスワード設定完了のお知らせ')
        .and have_body_text(sf_account_fc.LastName)
        .and have_body_text(sf_account_fc.FirstName)
        .and have_body_text(new_client_user_session_url)
        .and have_body_text(contact_ja_url)
    end
  end
end
