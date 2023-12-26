# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mypage::Client::Bookmarks', type: :request do
  subject do
    send_request
    response
  end

  let(:client_user) { FactoryBot.create(:client_user, :with_contact) }

  describe 'GET /mypage/cl/bookmarks' do
    before do
      sign_in(client_user)
    end

    it do
      is_expected.to have_http_status(:ok)
    end
  end
end
