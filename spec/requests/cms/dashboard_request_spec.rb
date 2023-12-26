# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Cms::Dashboards', type: :request do
  subject(:perfomr) do
    send_request
    response
  end

  describe 'GET /cms/' do
    let(:wp_user) { FactoryBot.build_stubbed(:wp_user) }

    context 'with signed in as wp_user' do
      before do
        sign_in wp_user
      end

      it do
        is_expected.to have_http_status(:ok)
      end
    end

    context 'without signed in' do
      it do
        is_expected.to redirect_to(new_wp_user_session_path)
      end
    end
  end
end
