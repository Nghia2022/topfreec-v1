# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'FcUsers::Passwords', type: :request do
  subject do
    send_request
    response
  end

  let(:response_body) { subject.body }

  describe 'GET /password/new' do
    it do
      is_expected.to have_http_status(:ok)
    end
    it do
      expect(response_body).to have_selector(:testid, 'fc_users/passwords')
    end

    context 'with alert' do
      subject do
        send_request
        Capybara.string(response.body)
      end

      before do
        allow_any_instance_of(FcUsers::PasswordsController).to receive(:flash).and_return({ alert: 'Alert' })
      end

      it do
        is_expected.to have_selector('.invalid-feedback li', text: 'Alert')
      end
    end
  end

  describe 'GET /password/edit' do
    shared_examples 'reset_password_token expired' do
      it do
        is_expected.to redirect_to(new_fc_user_password_path)
          .and(satisfy { flash[:alert] == 'URLの有効期限が切れました。新しくリクエストしてください。' })
      end
    end

    shared_examples 'password change help text' do
      it do
        expect(response_body).to have_content('英字(半角大文字)・英字(半角小文字)・数字(半角)・記号(半角)それぞれ最低1文字以上を含む、8文字以上のパスワードの設定をお願いいたします。')
      end
    end

    shared_context 'valid reset_password_token' do
      let(:params) do
        {
          reset_password_token:
        }
      end

      let!(:fc_user) { FactoryBot.create(:fc_user, :activated, reset_password_token: generated_token[1], reset_password_sent_at:) }
      let(:generated_token) { Devise.token_generator.generate(FcUser, :reset_password_token) }
      let(:reset_password_token) { generated_token[0] }
      let(:reset_password_sent_at) { Time.current }
    end

    context 'when reset_password_token is valid' do
      include_context 'valid reset_password_token'

      it do
        is_expected.to have_http_status(:ok)
      end

      include_examples 'password change help text'

      it do
        expect(response_body).to have_selector(:testid, 'v2022/fc_users/passwords')
      end
    end

    context 'when reset_password_token is invalid' do
      let(:params) do
        {
          reset_password_token: 'invalid'
        }
      end

      it_behaves_like 'reset_password_token expired'
    end

    context 'when reset_password_token is expired' do
      include_context 'valid reset_password_token' do
        let(:reset_password_sent_at) { 72.hours.ago }
      end

      it_behaves_like 'reset_password_token expired'
    end
  end

  describe 'POST /password' do
    context 'when do not enter an email' do
      it do
        is_expected.to have_http_status(:ok)
      end

      it do
        expect(response_body).to have_content('メールアドレスを入力してください')
      end
    end

    context 'when fc_user exists' do
      let!(:fc_user) { FactoryBot.create(:fc_user, :activated) }
      let(:sf_contact) { FactoryBot.build_stubbed(:sf_contact) }
      let(:params) do
        {
          fc_user: {
            email: fc_user.email
          }
        }
      end

      before do
        allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
      end

      it do
        expect do
          send_request
          fc_user.reload
        end.to change(fc_user, :reset_password_token).from(nil).to(be_present)
      end

      it do
        expect do
          perform_enqueued_jobs do
            send_request
          end
        end.to change { FcUserMailer.deliveries.count }.by(1)
      end
    end

    context 'when fc_user exists but not be activated' do
      let!(:fc_user) { FactoryBot.create(:fc_user) }
      let(:params) do
        {
          fc_user: {
            email: fc_user.email
          }
        }
      end

      it do
        expect do
          perform_enqueued_jobs do
            send_request
          end
        end.to(not_change { FcUserMailer.deliveries.count })
      end
    end

    context 'when fc_user not exists' do
      let(:params) do
        {
          fc_user: {
            email: Faker::Internet.email
          }
        }
      end

      it do
        expect do
          perform_enqueued_jobs do
            send_request
          end
        end.to(not_change { FcUserMailer.deliveries.count })
      end
    end

    context 'when contact exists but fc_user not exists' do
      let(:contact) { FactoryBot.create(:contact, :fc) }
      let(:sf_contact) { FactoryBot.build_stubbed(:sf_contact) }

      before do
        allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
      end

      let(:params) do
        {
          fc_user: {
            email: contact.email
          }
        }
      end

      it do
        expect do
          perform_enqueued_jobs do
            send_request
          end
        end.to(change { FcUserMailer.deliveries.count })
      end
    end

    context 'when contact of fc_company exists but fc_user not exists' do
      let(:contact) { FactoryBot.create(:contact, :fc_company) }
      let(:params) do
        {
          fc_user: {
            email: contact.email
          }
        }
      end
      let(:sf_contact) { FactoryBot.build_stubbed(:sf_contact) }

      before do
        allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
      end

      it do
        expect do
          perform_enqueued_jobs do
            send_request
          end
        end.to change { FcUserMailer.deliveries.count }.by(1)
      end
    end
  end

  describe 'PUT /password' do
    let!(:fc_user) { FactoryBot.create(:fc_user, :activated, reset_password_token: generated_token[1], reset_password_sent_at: Time.current) }
    let(:params) do
      {
        fc_user: {
          reset_password_token:,
          password:              new_password,
          password_confirmation: new_password
        }
      }
    end
    let(:generated_token) { Devise.token_generator.generate(FcUser, :reset_password_token) }
    let(:reset_password_token) { generated_token[0] }
    let(:new_password) { '#zH6eTaJbLuXjA1' }
    let(:sf_contact) { FactoryBot.build_stubbed(:sf_contact) }

    before do
      allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
    end

    context 'when reset_password_token and new password are valid' do
      it do
        is_expected.to redirect_to(new_fc_user_session_path)
      end

      context 'when changed password successfully' do
        subject do
          send_request
          fc_user.reload
        end

        it do
          is_expected.to be_valid_password new_password
        end
      end

      describe 'notify password changed via email' do
        it do
          expect do
            perform_enqueued_jobs do
              send_request
            end
          end.to change { FcUserMailer.deliveries.count }.by(1)
        end

        describe 'email' do
          subject { open_email(fc_user.email) }

          it do
            perform_enqueued_jobs do
              send_request
            end

            is_expected.to have_subject('【みらいワークス】パスワード設定完了・登録者限定コミュニティ「みらコミュ」のご案内(FreeConsultant.jp)')
          end
        end
      end
    end

    context 'when enter invalid params' do
      let(:params) do
        {
          fc_user: {
            reset_password_token:,
            password:              'aa',
            password_confirmation: 'bb'
          }
        }
      end

      it do
        expect(response_body).to have_content('パスワードが短すぎます')
          .and have_content('新しいパスワード（確認）が一致しません')
      end
    end

    context 'when reset_password_token is expired' do
      pending
    end

    context 'when reset_password_token is invalid' do
      pending
    end
  end

  describe 'GET /password/guide' do
    it do
      is_expected.to have_http_status(:ok)
    end
    it do
      expect(response_body).to have_selector(:testid, 'fc_users/passwords')
    end
  end
end
