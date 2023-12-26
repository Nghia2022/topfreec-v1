# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'FcUsers::Sessions', :erb, type: :request do
  subject do
    send_request
    response
  end

  describe 'GET /user/sign_in' do
    before do
      Recaptcha.configuration.site_key = 'test_key'
    end

    it do
      is_expected.to have_http_status(:ok)
    end

    it do
      expect(subject.body).to have_selector(:testid, 'fc_users/sessions/new')
    end
  end

  describe 'POST /user/sign_in' do
    let(:params) { valid_params }
    let(:valid_params) do
      {
        fc_user: {
          email:    fc_user.email,
          password: fc_user.password
        }
      }
    end

    context 'valid fc_user' do
      let!(:fc_user) { FactoryBot.create(:fc_user, :activated) }
      let(:contact) { fc_user.contact }
      let(:now) { Time.zone.parse('2020-10-01 00:00:00') }
      let(:user_agent) { Faker::Internet.user_agent }
      let(:headers) do
        {
          'User-Agent' => user_agent
        }
      end

      around do |ex|
        travel_to(now) { ex.run }
      end

      it do
        is_expected.to redirect_to(mypage_fc_root_path)
          .and have_http_status(:found)
      end

      it do
        expect do
          send_request
          fc_user.reload
          contact.reload
        end
          .to change { fc_user.user_agent }.from('').to(user_agent)
          .and change { contact.fcweb_logindatetime__c }.from(nil).to(now)
      end

      context 'without remember_me' do
        describe 'remember_me cookie' do
          it do
            send_request
            expect(cookies[:remember_fc_user_token]).to be_blank
          end
        end
      end

      context 'with remember_me' do
        let(:params) do
          valid_params.deep_merge(fc_user: { remember_me: '1' })
        end

        describe 'remember_me cookie' do
          it do
            send_request
            expect(cookies[:remember_fc_user_token]).to be_present
          end
        end
      end

      context 'when verify recaptcha is falied' do
        before do
          allow_any_instance_of(FcUsers::SessionsController).to receive(:verify_recaptcha).and_return(false)
        end

        it do
          is_expected.to have_http_status(:ok)
        end

        it do
          send_request
          expect(response.body).to have_no_content('プロフィールを編集')
        end
      end
    end

    context 'unconfirmed fc_user' do
      let!(:fc_user) { FactoryBot.create(:fc_user, :unconfirmed) }

      it do
        is_expected.to redirect_to(fc_user_session_path)
          .and have_http_status(:found)
      end
    end

    context 'wrong password' do
      let!(:fc_user) { FactoryBot.create(:fc_user) }
      let(:params) do
        {
          fc_user: {
            email:    fc_user.email,
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
end
