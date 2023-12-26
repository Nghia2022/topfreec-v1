# frozen_string_literal: true

class Api::V1::FcUsersController < ApplicationController
  skip_forgery_protection

  api :PUT, '/fc_users/:contact_sfid/activate', 'Activate user'
  api_version 'v1'
  param :contact_sfid, String, desc: 'Salesforce ID', required: true
  param :lead_no, String, desc: '申込者No', required: true
  def activate
    user = Fc::UserActivation::FcUser.find_by(lead_no: params[:lead_no])

    Contact.fetch_latest_contacts_from_sf
    Account.fetch_latest_accounts_from_sf

    if user&.activated?
      user.errors.add(:base, :already_activated)
      render json: user, serializer: ErrorSerializer, status: :unprocessable_entity
    else
      FcUsers::ActivateJob.perform_later(activate_params[:lead_no], activate_params[:contact_sfid])
      render body: nil, status: :accepted
    end
  end

  private

  def activate_params
    params.permit(:lead_no, :contact_sfid)
  end
end
