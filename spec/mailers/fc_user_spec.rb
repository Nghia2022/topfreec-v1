# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FcUserMailer, type: :mailer do
  describe '#activation_instructions' do
    let(:activation_token) { 'dummy' }
    let(:sf_account_fc) { FactoryBot.build_stubbed(:sf_account_fc) }
    let(:fc_user) { FactoryBot.build_stubbed(:fc_user, :activated, activation_token:) }
    let(:email) { FcUserMailer.activation_instructions(fc_user:, activation_token:) }

    before do
      allow(Salesforce::Account).to receive(:find).and_return(sf_account_fc)
    end

    it do
      expect(email).to have_subject('【みらいワークス】会員登録手続き完了のご案内と会員情報入力のお願い(FreeConsultant.jp)')
        .and have_body_text(sf_account_fc.LastName)
        .and have_body_text(sf_account_fc.FirstName)
        .and have_body_text(fc_user_activation_url(token: activation_token))
        .and have_body_text(contact_mypage_usage_url)
        .and have_body_text(commmune_signin_url)
        .and have_body_text(corporation_community_instructions_pdf_url)
        .and have_body_text(commmune_faq_url)
        .and have_body_text(contact_ja_url)
    end
  end

  describe '#confirmation_instructions' do
    let(:confirmation_token) { 'dummy' }
    let(:sf_account_fc) { FactoryBot.build_stubbed(:sf_account_fc) }
    let(:fc_user) { FactoryBot.build_stubbed(:fc_user, :activated, confirmation_token:, unconfirmed_email: Faker::Internet.email) }
    let(:email) { FcUserMailer.confirmation_instructions(fc_user, confirmation_token) }

    before do
      allow(fc_user.account).to receive(:to_sobject).and_return(sf_account_fc)
    end

    it do
      expect(email).to have_subject('【みらいワークス】ご登録メールアドレスの変更のご確認(FreeConsultant.jp)')
        .and have_body_text(sf_account_fc.LastName)
        .and have_body_text(sf_account_fc.FirstName)
        .and have_body_text(fc_user_confirmation_url(confirmation_token:))
    end
  end

  describe '#password_change' do
    let(:sf_account_fc) { FactoryBot.build_stubbed(:sf_account_fc) }
    let(:fc_user) { FactoryBot.build_stubbed(:fc_user, :activated) }
    let(:email) { FcUserMailer.password_change(fc_user) }

    before do
      allow(fc_user.contact).to receive(:to_sobject).and_return(sf_account_fc)
    end

    it do
      expect(email).to have_subject('【みらいワークス】パスワード設定完了・登録者限定コミュニティ「みらコミュ」のご案内(FreeConsultant.jp)')
        .and have_body_text(sf_account_fc.LastName)
        .and have_body_text(sf_account_fc.FirstName)
        .and have_body_text(contact_mypage_usage_url)
        .and have_body_text(commmune_signin_url)
        .and have_body_text(corporation_community_instructions_pdf_url)
        .and have_body_text(commmune_faq_url)
        .and have_body_text(contact_ja_url)
    end
  end

  describe '#reset_password_instructions' do
    let(:reset_password_token) { 'dummy' }
    let(:sf_account_fc) { FactoryBot.build_stubbed(:sf_account_fc) }
    let(:fc_user) { FactoryBot.build_stubbed(:fc_user, :activated, reset_password_token:) }
    let(:email) { FcUserMailer.reset_password_instructions(fc_user, reset_password_token) }

    before do
      allow(fc_user.contact).to receive(:to_sobject).and_return(sf_account_fc)
    end

    it do
      expect(email).to have_subject('【みらいワークス】パスワード設定用URLのご送付(FreeConsultant.jp)')
        .and have_body_text(sf_account_fc.LastName)
        .and have_body_text(sf_account_fc.FirstName)
        .and have_body_text(edit_fc_user_password_url(@fc_user, reset_password_token:))
        .and have_body_text(contact_ja_request_url)
    end
  end
end
