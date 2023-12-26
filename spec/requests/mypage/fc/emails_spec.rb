# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mypage::Fc::Emails', type: :request do
  subject(:perform) do
    send_request
    response
  end

  let(:response_body) { perform.body }

  let(:fc_user) { FactoryBot.create(:fc_user, :activated) }
  let(:sf_account_fc) { FactoryBot.build_stubbed(:sf_account_fc) }

  describe 'GET /mypage/fc/email/edit' do
    before do
      sign_in(fc_user)
    end

    it do
      is_expected.to have_http_status(:ok)
    end
  end

  describe 'PUT /mypage/fc/email' do
    before do
      allow_any_instance_of(Account).to receive(:to_sobject).and_return(sf_account_fc)
      sign_in(fc_user)
    end

    context 'valid' do
      let(:params) do
        {
          fc_user: {
            email:              'test@example.com',
            email_confirmation: 'test@example.com'
          }
        }
      end

      it do
        is_expected.to redirect_to mypage_fc_settings_path
      end

      it do
        expect do
          perform_enqueued_jobs do
            perform
          end
        end.to change { FcUserMailer.deliveries.count }.by(1)
      end

      it do
        perform_enqueued_jobs do
          perform
        end

        fc_user.reload
        email = open_email(fc_user.unconfirmed_email)
        expect(email).to deliver_to(fc_user.unconfirmed_email)
      end

      it do
        expect do
          perform
          fc_user.reload
        end.to change(fc_user, :unconfirmed_email).from(nil).to(params.dig(:fc_user, :email))
      end
    end

    context 'invalid' do
      context 'not changed' do
        let(:params) do
          {
            fc_user: {
              email: fc_user.email
            }
          }
        end

        it do
          is_expected.to have_http_status(:unprocessable_entity)
        end

        it do
          expect(response_body).to have_content('現在のメールアドレスと同じです')
        end

        it do
          expect do
            perform
            fc_user.reload
          end.to_not change(fc_user, :unconfirmed_email)
        end
      end

      context 'email was blanked' do
        let(:params) do
          {
            fc_user: {
              email: ''
            }
          }
        end

        it do
          expect(response_body).to have_content('メールアドレスの入力は必須です')
        end
      end

      context 'not confirmation' do
        let(:params) do
          {
            fc_user: {
              email:              'test@example.com',
              email_confirmation: 'test@example.org'
            }
          }
        end

        it do
          expect(response_body).to have_content('メールアドレスが一致しません')
        end
      end

      context 'already registered' do
        let(:existing_fc_user) { FactoryBot.create(:fc_user, :activated) }
        let(:params) do
          {
            fc_user: {
              email: existing_fc_user.email
            }
          }
        end

        it do
          expect(response_body).to have_content('メールアドレスは既に登録済みです')
        end
      end
    end
  end
end
