# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mypage::Client::Passwords', type: :request do
  subject do
    send_request
    response
  end

  let!(:client_user) { FactoryBot.create(:client_user, :with_contact) }
  let(:password) { client_user.password }
  let(:current_password) { password }
  let(:sf_contact) { FactoryBot.build_stubbed(:sf_contact) }

  let(:response_body) { subject.body }

  describe 'GET /mypage/cl/password/edit' do
    before do
      sign_in(client_user)
    end

    it do
      is_expected.to have_http_status(:ok)
    end
  end

  describe 'PUT /mypage/cl/password' do
    let(:params) do
      {
        client_user: {
          current_password:,
          password:              new_password,
          password_confirmation:
        }
      }
    end
    let(:new_password) { '#zH6eTaJbLuXjA1' }
    let(:password_confirmation) { new_password }

    before do
      allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
      sign_in(client_user)
    end

    context 'with valid password' do
      it do
        is_expected.to redirect_to mypage_client_settings_path
      end

      describe 'is authenticatable with new password after password changed' do
        it do
          send_request
          client_user.reload
          expect(client_user).to be_valid_password(new_password)
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

    context 'with invalid password' do
      shared_examples_for 'password not changed' do
        it do
          is_expected.to have_http_status(:unprocessable_entity)
        end

        it do
          expect do
            subject
            client_user.reload
          end.to_not change(client_user, :encrypted_password)
        end
      end

      context 'current_password not matched' do
        let(:current_password) { 'wrong-current_password' }

        include_examples 'password not changed'

        it do
          expect(response_body).to have_content('現在のパスワードは不正な値です')
        end
      end

      context 'empty' do
        let(:new_password) { '' }

        include_examples 'password not changed'

        it do
          expect(response_body).to have_content('パスワードを入力してください')
        end
      end

      context 'too short' do
        let(:new_password) { 'short' }

        include_examples 'password not changed'

        it do
          expect(response_body).to have_content('パスワードは8文字以上で入力してください')
        end
      end

      context 'confirmation is not same' do
        let(:password_confirmation) { 'not-same' }

        include_examples 'password not changed'

        it do
          expect(response_body).to have_content('パスワード（確認用）とパスワードの入力が一致しません')
        end
      end
    end
  end
end
