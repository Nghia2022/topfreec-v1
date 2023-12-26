# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mypage::Roots', type: :request do
  subject do
    send_request
    response
  end

  describe 'GET /mypage' do
    context 'when fc user' do
      let(:fc_user) { FactoryBot.create(:fc_user, :activated) }

      before do
        sign_in(fc_user)
      end

      it do
        is_expected.to redirect_to mypage_fc_root_path
      end
    end

    context 'when client user' do
      let(:client_user) { FactoryBot.create(:client_user) }

      before do
        sign_in(client_user)
      end

      it do
        is_expected.to redirect_to mypage_client_root_path
      end
    end
  end
end
