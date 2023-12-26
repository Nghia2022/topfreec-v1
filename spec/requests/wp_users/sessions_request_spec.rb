# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'WpUsers::Sessions', type: :request do
  subject(:perform) do
    send_request
    response
  end

  describe 'GET /wp_users/sign_in' do
    it do
      is_expected.to have_http_status(:ok)
    end
  end

  describe 'POST /wp_users/sign_in' do
    let(:wp_user) { FactoryBot.build_stubbed(:wp_user, password: 'password') }
    let(:params) do
      {
        wp_user: {
          user_login: wp_user.user_login,
          password:   'password'
        }
      }
    end

    context 'when user is found' do
      before do
        allow(Wordpress::WpUser).to receive(:find_by).and_return(wp_user)
      end

      it do
        is_expected.to redirect_to(cms_root_path)
      end
    end

    context 'when user is found' do
      it do
        is_expected.to redirect_to(new_wp_user_session_path)
      end
    end
  end

  describe 'DELETE /wp_users/sign_out' do
    let(:wp_user) { FactoryBot.build_stubbed(:wp_user, password: 'password') }

    before do
      sign_in(wp_user)
    end

    it do
      is_expected.to redirect_to(new_wp_user_session_path)
    end

    it do
      perform
      expect(session.keys).not_to include('warden.user.wp_user.key')
    end
  end
end
