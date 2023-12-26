# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Doorkeeper::TokensController', type: :request do
  subject(:perform) do
    send_request
    response
  end

  let(:fc_user) { FactoryBot.create(:fc_user, :activated, contact_trait:).reload }
  let(:contact_trait) { [] }
  let(:url) { "#{Rails.configuration.x.default_url_options.protocol}://#{Rails.configuration.x.default_url_options.host}" }
  let!(:oauth_application) { FactoryBot.create(:oauth_application) }
  let!(:oauth_access_grant) do
    FactoryBot.create(
      :oauth_access_grant,
      application:       oauth_application,
      resource_owner_id: fc_user.id,
      code_challenge:
    )
  end
  let!(:oauth_openid_request) { FactoryBot.create(:oauth_openid_request, access_grant: oauth_access_grant, nonce: 'abc') }
  let(:code_verifier) { SecureRandom.hex(28) }
  let(:code_challenge) { Oauth::AccessGrant.generate_code_challenge(code_verifier) }
  let(:assertion) do
    JWT.encode(
      {
        iat: Time.now.to_i,
        exp: 1.minute.from_now.to_i,
        jti: SecureRandom.hex(16),
        iss: oauth_application.uid,
        sub: oauth_application.uid,
        aud: %W["#{url}" "#{url}/oauth/token"]
      },
      oauth_application.secret,
      'HS256'
    )
  end

  describe 'POST /oauth/token' do
    let(:params) do
      {
        client_id:             oauth_application.uid,
        client_assertion:      assertion,
        client_assertion_type: 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
        redirect_uri:          oauth_application.redirect_uri,
        grant_type:            'authorization_code',
        code:                  oauth_access_grant.plaintext_token,
        code_verifier:
      }
    end

    it do
      is_expected.to have_http_status(:ok)
    end

    it do
      perform
      response_body = response.parsed_body
      expect(Doorkeeper::AccessToken.last.token).to eq Doorkeeper::AccessToken.secret_strategy.transform_secret(response_body['access_token'])
    end

    describe 'expires_in' do
      it do
        perform
        expect(Doorkeeper::AccessToken.last.expires_in).to eq(Doorkeeper.configuration.access_token_expires_in)
      end
    end
  end
end
