# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Oauth::Userinfo', type: :request do
  subject(:perform) do
    send_request
    response
  end

  describe 'GET /oauth/userinfo' do
    let(:access_token) do
      FactoryBot.create(:oauth_access_token,
                        resource_owner_id: fc_user.id,
                        scopes:            'openid email')
    end
    let(:fc_user) { FactoryBot.create(:fc_user, :activated) }

    describe 'Doorkeeper.config.access_token_methods' do
      context 'with from_bearer_authorization' do
        let(:headers) do
          {
            Authorization: "Bearer #{access_token.plaintext_token}"
          }
        end

        it do
          is_expected.to have_http_status(:ok)
        end

        it do
          perform
          expect(response.body).to be_json_as(
            sub:   be_present,
            email: fc_user.email
          )
        end
      end

      context 'with from_access_token_param' do
        let(:params) do
          {
            access_token: access_token.plaintext_token
          }
        end

        it do
          expect { perform }.to raise_error(Doorkeeper::Errors::TokenUnknown)
        end
      end

      context 'with from_bearer_param' do
        let(:params) do
          {
            bearer_token: access_token.plaintext_token
          }
        end

        it do
          expect { perform }.to raise_error(Doorkeeper::Errors::TokenUnknown)
        end
      end
    end
  end
end
