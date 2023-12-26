# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OauthSessions', type: :request do
  subject do
    send_request
    response
  end

  let(:email) { 'test@example.com' }

  describe 'GET /auth/salesforce/callback' do
    context 'when success' do
      before do
        OmniAuth.config.test_mode = true
        OmniAuth.config.add_mock(:salesforce, { uid: '12345', info: { email: } })
      end

      it { is_expected.to redirect_to(admin_root_path) }
      it do
        subject
        expect(session[:oauth_email]).to eq(email)
      end
    end

    context 'when failure' do
      before do
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[:salesforce] = :invalid_credentials
      end

      it { is_expected.to redirect_to('/auth/failure?message=invalid_credentials&strategy=salesforce') }
    end
  end
end
