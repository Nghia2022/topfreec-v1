# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'PasswordExpireds', type: :request do
  subject do
    send_request
    response
  end

  xdescribe 'GET /password_expired' do
    let(:fc_user) { FactoryBot.create(:fc_user) }

    before do
      sign_in(fc_user)
      # FIXME: セッションにpassword_expiredが設定出来ない(rspec-railsが古いのが原因？）ので保留
    end

    it do
      is_expected.to have_http_status(:ok)
    end
  end
end
