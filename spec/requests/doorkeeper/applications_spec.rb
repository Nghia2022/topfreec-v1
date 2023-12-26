# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Doorkeeper::Application', type: :request do
  subject(:perform) do
    send_request
    response
  end

  before do
    inject_session(oauth_email: Faker::Internet.email(domain: 'mirai-works.co.jp'))
  end

  describe 'GET /oauth/applications/:id' do
    let!(:oauth_application) { FactoryBot.create(:oauth_application) }
    let(:id) { oauth_application.id }

    it do
      is_expected.to have_http_status(:ok)
    end

    it do
      perform
      expect(response.body).to include('Secret hashed')
    end
  end
end
