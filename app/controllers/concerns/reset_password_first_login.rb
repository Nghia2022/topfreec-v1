# frozen_string_literal: true

module ResetPasswordFirstLogin
  extend ActiveSupport::Concern

  def request_reset_password
    session[:reset_password] = true
  end

  def clear_request_reset_password
    session.delete :reset_password
  end

  def request_reset_password?
    session[:reset_password].present?
  end

  def redirect_to_reset_password
    redirect_to new_mypage_fc_password_path
  end
end
