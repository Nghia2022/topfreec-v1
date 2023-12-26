# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mypage::Fc::Profiles::Qualifications', :erb, type: :request do
  subject(:perform) do
    send_request
    response
  end

  let!(:fc_user) { FactoryBot.create(:fc_user, :activated) }

  describe 'GET /mypage/fc/profile/qualification/edit' do
    before do
      sign_in(fc_user)
    end

    it do
      is_expected.to have_http_status(:ok)
    end
  end

  describe 'PUT /mypage/fc/profile/qualification' do
    before do
      sign_in(fc_user)
    end

    let(:valid_params) do
      {
        qualification: {
          license: Faker::Lorem.paragraphs(number: 3).join("\n")
        }
      }
    end

    context 'with valid params' do
      let(:params) do
        valid_params
      end

      it do
        is_expected.to redirect_to mypage_fc_profile_path
      end

      it do
        perform
        expect(fc_user.person.decorate).to have_attributes(
          license: params[:qualification][:license]
        )
      end
    end

    context 'with invalid params' do
      let(:params) do
        valid_params.deep_merge(qualification: { license: 'a' * 501 })
      end

      it do
        is_expected.to have_http_status(:unprocessable_entity)
      end

      it do
        expect(perform.body).to have_content('保有資格は500文字以内で入力してください')
      end
    end
  end
end
