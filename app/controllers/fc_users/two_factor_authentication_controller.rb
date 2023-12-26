# frozen_string_literal: true

class FcUsers::TwoFactorAuthenticationController < Devise::TwoFactorAuthenticationController
  layout 'welcome'

  helper_method :user

  private

  # :nocov:
  def user
    @user ||= current_user.decorate
  end
  # :nocov:

  concerning :Breadcrumbs do
    included do
      add_breadcrumb 'TOP', :root_path
      add_breadcrumb '二段階認証', :fc_user_two_factor_authentication_path
    end
  end
end
