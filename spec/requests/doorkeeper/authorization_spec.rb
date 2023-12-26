# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Doorkeeper::Authorization', type: :request do
  subject(:perform) do
    send_request
    response
  end

  let(:oauth_application) { FactoryBot.create(:oauth_application, scopes: 'openid email') }
  let(:fc_user) { FactoryBot.create(:fc_user, :activated) }

  describe 'GET /oauth/authorize' do
    before do
      sign_in fc_user
    end

    let(:params) do
      {
        client_id:             oauth_application.uid,
        state:                 'xyz',
        scope:                 oauth_application.scopes,
        redirect_uri:          oauth_application.redirect_uri,
        nonce:                 'abc',
        code_challenge:        'BqjcgAHAHUY_7BfU3Fz2c7Nhv0MPhv9lzG05qYMeCjo',
        code_challenge_method: 'S256'
      }
    end

    it do
      is_expected.to have_http_status(:ok)
    end
  end

  describe 'POST /oauth/authorize' do
    before do
      sign_in fc_user
    end

    let(:params) do
      {
        client_id:             oauth_application.uid,
        state:                 'xyz',
        response_type:         'code',
        scope:                 oauth_application.scopes,
        redirect_uri:          oauth_application.redirect_uri,
        nonce:                 'abc',
        code_challenge:        'BqjcgAHAHUY_7BfU3Fz2c7Nhv0MPhv9lzG05qYMeCjo',
        code_challenge_method: 'S256'
      }
    end

    it do
      is_expected.to have_http_status(:redirect)
    end

    it do
      perform
      expect(response.body).to include('code=')
    end

    describe 'expires_in' do
      it do
        perform
        expect(Doorkeeper::AccessGrant.last.expires_in).to eq(Doorkeeper.configuration.authorization_code_expires_in)
      end
    end
  end
end
