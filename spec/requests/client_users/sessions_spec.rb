# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ClientUsers::Sessions', :erb, type: :request do
  subject do
    send_request
    response
  end

  describe 'GET /client/sign_in' do
    before do
      Recaptcha.configuration.site_key = 'test_key'
    end

    it { is_expected.to have_http_status(:ok) }
    it { expect(subject.body).to have_link('利用規約', href: mirai_works_policy_url) }
  end

  describe 'POST /client/sign_in' do
    let(:params) { valid_params }
    let(:valid_params) do
      {
        client_user: {
          email:    client_user.email,
          password: client_user.password
        }
      }
    end

    shared_examples 'signs in as client user' do
      context 'valid user' do
        let!(:client_user) { FactoryBot.create(:client_user) }
        let(:user_agent) { Faker::Internet.user_agent }
        let(:headers) do
          {
            'User-Agent' => user_agent
          }
        end

        it { is_expected.to have_http_status(:found) }

        it 'redirects to mypage' do
          is_expected.to redirect_to mypage_client_root_path
        end

        it do
          expect do
            send_request
            client_user.reload
          end
            .to change { client_user.user_agent }.from('').to(user_agent)
        end

        context 'without remember_me' do
          describe 'remember_me cookie' do
            it do
              send_request
              expect(cookies[:remember_client_user_token]).to be_blank
            end
          end
        end

        context 'with remember_me' do
          let(:params) do
            valid_params.deep_merge(client_user: { remember_me: '1' })
          end

          describe 'remember_me cookie' do
            it do
              send_request
              expect(cookies[:remember_client_user_token]).to be_present
            end
          end
        end

        context 'when verify recaptcha is falied' do
          before do
            allow_any_instance_of(ClientUsers::SessionsController).to receive(:verify_recaptcha).and_return(false)
          end

          it do
            is_expected.to have_http_status(:ok)
          end

          it do
            send_request
            expect(response.body).to have_content('企業ログイン')
          end
        end
      end

      context 'unconfirmed user' do
        let!(:client_user) { FactoryBot.create(:client_user, :unconfirmed) }

        it { is_expected.to have_http_status(:found) }
        it { is_expected.to redirect_to client_user_session_path }
      end

      context 'wrong password' do
        let!(:client_user) { FactoryBot.create(:client_user) }
        let(:params) do
          {
            client_user: {
              email:    client_user.email,
              password: 'wrong_password'
            }
          }
        end

        it do
          send_request
          expect(flash).to have_attributes(alert: 'メールアドレスかパスワードが間違っています')
        end
      end
    end

    include_examples 'signs in as client user'
  end
end
