# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mypage::Fc::Passwords', type: :request do
  subject do
    send_request
    response
  end

  let(:response_body) { subject.body }

  let!(:fc_user) { FactoryBot.create(:fc_user, :activated) }
  let(:password) { '#zH6eTaJbLuXjA1' }
  let(:current_password) { fc_user.password }

  describe 'GET /mypage/fc/password/new' do
    let!(:fc_user) { FactoryBot.create(:fc_user, :activated, registration_completed_at: nil) }

    before do
      sign_in(fc_user)
    end

    it do
      is_expected.to have_http_status(:ok)
    end
  end

  describe 'POST /mypage/fc/password' do
    let!(:fc_user) { FactoryBot.create(:fc_user, :activated, registration_completed_at: nil) }
    let(:sf_contact) { FactoryBot.build_stubbed(:sf_contact, :fc) }

    let(:params) do
      {
        fc_user: {
          password:,
          password_confirmation: password
        }
      }
    end

    before do
      allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
      sign_in(fc_user)
    end

    it do
      is_expected.to redirect_to mypage_fc_root_path
    end

    it do
      expect do
        perform_enqueued_jobs do
          subject
        end
      end.not_to change(FcUserMailer.deliveries, :count)
    end
  end

  describe 'GET /mypage/fc/password/edit' do
    before do
      sign_in(fc_user)
    end

    it do
      is_expected.to have_http_status(:ok)
    end
  end

  describe 'PUT /mypage/fc/password' do
    let(:params) do
      {
        fc_user: {
          current_password:,
          password:              new_password,
          password_confirmation:
        }
      }
    end
    let(:new_password) { '#zH6eTaJbLuXjA1' }
    let(:password_confirmation) { new_password }

    before do
      sign_in(fc_user)
    end

    context 'with valid password' do
      let(:phone_number) { Faker::PhoneNumber.cell_phone.delete('-') }
      let(:sf_contact) { FactoryBot.build_stubbed(:sf_contact) }
      before do
        allow_any_instance_of(FcUser).to receive(:phone).and_return(phone_number)
        allow_any_instance_of(FcUser).to receive(:unconfirmed_phone).and_return(nil)
        allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
      end

      it do
        is_expected.to have_http_status(:created)
          .and(satisfy { |response| response.headers['Location'] == mypage_fc_settings_path })
      end

      describe 'is authenticatable with new password after password changed' do
        it do
          send_request
          fc_user.reload
          expect(fc_user).to be_valid_password(new_password)
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

    context 'with invalid password' do
      shared_examples_for 'password not changed' do
        it do
          is_expected.to have_http_status(:unprocessable_entity)
        end

        it do
          expect do
            subject
            fc_user.reload
          end.to_not change(fc_user, :encrypted_password)
        end
      end

      context 'current_password not matched' do
        let(:current_password) { 'wrong-current_password' }

        it_behaves_like 'password not changed'
      end

      context 'current_password blank' do
        let(:current_password) { '' }

        it do
          expect(response_body).to have_content('現在のパスワードを入力してください')
        end
      end

      context 'current_password invalid' do
        let(:current_password) { 'invalid_password' }

        it { expect(response_body).to have_content('現在のパスワードが一致しません') }
      end

      context 'empty' do
        let(:new_password) { '' }

        it_behaves_like 'password not changed'
      end

      context 'too short' do
        let(:new_password) { 'short' }

        it_behaves_like 'password not changed'
      end

      context 'confirmation is not same' do
        let(:password_confirmation) { 'not-same' }

        it_behaves_like 'password not changed'
      end
    end
  end
end
