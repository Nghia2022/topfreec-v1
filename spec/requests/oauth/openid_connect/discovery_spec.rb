# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Oauth::OpenidConnect::Discoveries', type: :request do
  subject(:perform) do
    send_request
    response
  end

  describe 'GET /.well-known/openid-configuration' do
    let(:headers) do
      {
        Host: 'www.example.com'
      }
    end

    it do
      is_expected.to have_http_status(:ok)
    end

    it do
      perform
      expect(response.body).to be_json_including(
        issuer:                                'https://www.example.com',
        token_endpoint_auth_methods_supported: %w[client_secret_basic client_secret_post client_secret_jwt]
      )
    end
  end
end
