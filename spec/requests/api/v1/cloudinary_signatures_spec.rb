# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::CloudinarySignatures', type: :request do
  subject do
    send_request
    response
  end

  describe 'POST /api/v1/cloudinary_signatures' do
    let(:params) do
      {
        params_to_sign: { data: 'test' }
      }
    end

    before do
      allow(Cloudinary::Utils).to receive(:api_sign_request).and_return('signed')
    end

    it '', :show_in_doc do
      is_expected.to have_http_status(:ok)
    end

    it do
      send_request
      expect(response_json).to include(
        'signature' => 'signed'
      )
    end
  end
end
