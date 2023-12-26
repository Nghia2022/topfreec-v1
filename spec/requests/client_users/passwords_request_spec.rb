# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ClientUsers::Passwords', type: :request do
  subject do
    send_request
    response
  end

  let(:response_body) { subject.body }

  describe 'GET /client/password/new' do
    shared_examples 'shows new page' do
      it do
        is_expected.to have_http_status(:ok)
      end

      context 'with alert' do
        subject do
          send_request
          Capybara.string(response.body)
        end

        before do
          allow_any_instance_of(ClientUsers::PasswordsController).to receive(:flash).and_return({ alert: 'Alert' })
        end

        it do
          is_expected.to have_selector('.invalid-feedback li', text: 'Alert')
        end
      end
    end

    include_examples 'shows new page'
  end

  describe 'GET /client/password/edit' do
    shared_examples 'shows edit page' do
      shared_examples 'reset_password_token expired' do
        it do
          is_expected.to redirect_to(new_client_user_password_path)
            .and(satisfy { flash[:alert] == 'URLの有効期限が切れました。新しくリクエストしてください。' })
        end
      end

      shared_context 'valid reset_password_token' do
        let(:params) do
          {
            reset_password_token:
          }
        end

        let!(:client_user) { FactoryBot.create(:client_user, reset_password_token: generated_token[1], reset_password_sent_at:) }
        let(:generated_token) { Devise.token_generator.generate(FcUser, :reset_password_token) }
        let(:reset_password_token) { generated_token[0] }
        let(:reset_password_sent_at) { Time.current }
      end

      context 'when reset_password_token is valid' do
        include_context 'valid reset_password_token'

        it do
          is_expected.to have_http_status(:ok)
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

    include_examples 'shows edit page'
  end

  describe 'POST /client/password' do
    shared_examples 'creates password' do
      context 'when do not enter an email' do
        it do
          is_expected.to have_http_status(:ok)
        end

        it do
          send_request
          expect(response.body).to have_content('メールアドレスを入力してください')
        end
      end

      shared_examples 'send reset password instructions' do
        it do
          perform_enqueued_jobs do
            send_request
          end
          email = open_last_email

          expect(email).to deliver_to(contact.email)
            .and have_subject('パスワード設定用URLのご送付')
        end
      end

      context 'when contact exists and client_user not ecists' do
        let!(:contact) { FactoryBot.create(:contact, :client) }
        let(:sf_contact) { FactoryBot.build_stubbed(:sf_contact) }
        let(:params) do
          {
            client_user: {
              email: contact.email
            }
          }
        end

        before do
          allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
        end

        it do
          is_expected.to(satisfy { ClientUser.last.email == contact.email })
        end

        it do
          expect do
            perform_enqueued_jobs do
              send_request
            end
          end.to change { ClientUser.exists?(email: contact.email) }.from(false).to(true)
            .and change { ClientUser.count }.by(1)
            .and change { ClientUserMailer.deliveries.count }.by(1)
        end

        it_behaves_like 'send reset password instructions'
      end

      context 'when contact and client_user exists' do
        let!(:contact) { FactoryBot.create(:contact, :client) }
        let!(:client_user) { FactoryBot.create(:client_user, email: contact.email, contact:) }
        let(:sf_contact) { FactoryBot.build_stubbed(:sf_contact) }
        let(:params) do
          {
            client_user: {
              email: contact.email
            }
          }
        end

        before do
          allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
        end

        it do
          expect do
            perform_enqueued_jobs do
              send_request
            end
          end.to not_change { ClientUser.exists?(email: contact.email) }.from(true)
            .and not_change { ClientUser.count }
            .and change { ClientUserMailer.deliveries.count }.by(1)
        end

        it_behaves_like 'send reset password instructions'
      end

      context 'when contact is not exists' do
        let(:invalid_email) { Faker::Internet.email }
        let(:params) do
          {
            client_user: {
              email: invalid_email
            }
          }
        end

        it do
          expect do
            perform_enqueued_jobs do
              send_request
            end
          end.to not_change { ClientUser.exists?(email: invalid_email) }.from(false)
            .and(not_change { ClientUser.count })
            .and(not_change { ClientUserMailer.deliveries.count })
        end
      end
    end

    include_examples 'creates password'
  end

  describe 'PUT /client/password' do
    shared_examples 'changes password' do
      let!(:client_user) { FactoryBot.create(:client_user, :with_contact, reset_password_token: generated_token[1], reset_password_sent_at: Time.current) }
      let(:params) do
        {
          client_user: {
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
          is_expected.to redirect_to(new_client_user_session_path)
        end

        context 'when changed password successfully' do
          subject do
            send_request
            client_user.reload
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
            end.to change { ClientUserMailer.deliveries.count }.by(1)
          end

          describe 'email' do
            subject { open_email(client_user.email) }

            it do
              perform_enqueued_jobs do
                send_request
              end

              is_expected.to have_subject('パスワード設定完了のお知らせ')
            end
          end
        end
      end

      context 'when enter invalid params' do
        let(:params) do
          {
            client_user: {
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

    include_examples 'changes password'
  end

  describe 'GET /client/password/guide' do
    it do
      is_expected.to have_http_status(:ok)
    end
  end
end
