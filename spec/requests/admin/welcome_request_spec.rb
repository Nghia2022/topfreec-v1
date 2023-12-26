# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Welcomes', type: :request do
  subject do
    send_request
    response
  end

  describe 'GET /fcweb-admin-01' do
    it { is_expected.to have_http_status(:ok) }
  end
end
