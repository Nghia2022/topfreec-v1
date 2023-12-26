# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'FcUsers::Activations', type: :request do
  subject(:perform) do
    send_request
    response
  end

  shared_context 'with invalid token' do
    let(:params) do
      {
        token: 'invalid-token'
      }
    end

    it do
      is_expected.to have_http_status(:forbidden)
    end

    it do
      expect(perform.body).to have_content('無効なURLか、すでに本人確認処理が完了しています。')
    end
  end

  describe 'GET /user/activation' do
    let(:contact) { FactoryBot.create(:contact, :fc) }
    let!(:fc_user) { FactoryBot.create(:fc_user, :unconfirmed, contact:, activation_token: generated_token[1]) }
    let(:generated_token) { Devise.token_generator.generate(FcUser, :activation_token) }
    let(:activation_token) { generated_token[0] }
    let(:now) { Time.zone.parse('2020-10-01 00:00:00') }

    around do |ex|
      travel_to(now) { ex.run }
    end

    context 'when token is valid' do
      let(:params) do
        {
          token: activation_token
        }
      end

      it do
        is_expected.to redirect_to mypage_fc_registration_url
      end

      it do
        expect do
          send_request
          fc_user.reload
        end.to change(fc_user, :activated?).from(false).to(true)
          .and change(fc_user, :confirmed?).from(false).to(true)
          .and change(fc_user, :current_sign_in_at).from(nil).to(now)
          .and change(fc_user, :sign_in_count).from(0).to(1)
      end
    end

    context 'when token is invalid' do
      include_context 'with invalid token'

      it do
        expect(perform.body).to have_selector(:testid, 'fc_users/activations/activation_error')
      end
    end
  end
end
