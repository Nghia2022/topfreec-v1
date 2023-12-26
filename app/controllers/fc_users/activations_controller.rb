# frozen_string_literal: true

class FcUsers::ActivationsController < ApplicationController
  include ResetPasswordFirstLogin
  layout 'welcome'

  def show
    fc_user = Fc::UserActivation::FcUser.activate_by_token(token)
    if fc_user.persisted?
      request_reset_password
      sign_in(fc_user)
      redirect_to mypage_fc_registration_url
    else
      render 'activation_error', status: :forbidden
    end
  end

  private

  def token
    @token ||= params.fetch(:token)
  end
end
