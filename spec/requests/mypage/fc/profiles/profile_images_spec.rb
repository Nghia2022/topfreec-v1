# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'MyPage::Fc::Profiles::ProfileImages', type: :request do
  subject do
    send_request
    response
  end

  let(:fc_user) { FactoryBot.create(:fc_user, :activated) }

  before do
    sign_in(fc_user)
  end

  describe 'GET /mypage/fc/profile/profile_image/edit' do
    before do
      sign_in(fc_user)
    end

    it do
      is_expected.to have_http_status(:ok)
    end
  end

  describe 'PATCH /mypage/fc/profile/profile_image' do
    let(:params) do
      {
        fc_user: {
          profile_image: 'http://example.com/example.png'
        }
      }
    end

    context 'when valid' do
      let(:params) do
        {
          fc_user: {
            profile_image: 'http://example.com/example.png'
          }
        }
      end

      it '', :show_in_doc do
        is_expected.to have_http_status(:no_content)
      end
    end

    context 'when invalid' do
      let(:params) do
        {
          fc_user: {
            profile_image: ''
          }
        }
      end

      it '', :show_in_doc do
        is_expected.to have_http_status(:unprocessable_entity)
      end
    end
  end
end
