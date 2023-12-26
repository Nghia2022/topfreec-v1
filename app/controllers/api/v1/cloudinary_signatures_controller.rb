# frozen_string_literal: true

class Api::V1::CloudinarySignaturesController < ApplicationController
  skip_forgery_protection

  api :POST, '/cloudinary_signatures', 'Generate signed signature'
  api_version 'v1'
  param :params_to_sign, Hash, desc: '署名用データ', required: true
  def create
    signature = Cloudinary::Utils.api_sign_request(
      params[:params_to_sign].permit!.to_h,
      Rails.application.credentials.dig(:cloudinary, :api_secret)
    )
    render json: { signature: }
  end
end
