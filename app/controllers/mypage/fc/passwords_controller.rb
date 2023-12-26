# frozen_string_literal: true

class Mypage::Fc::PasswordsController < Mypage::Fc::BaseController
  include ResetPasswordFirstLogin

  skip_before_action :verify_registration_completed, only: %i[new create]
  before_action :authorize_resource
  before_action :set_header_options

  def new; end

  def edit
    render layout: 'modal'
  end

  def create
    fc_user.skip_password_change_notification!
    if fc_user.update(permitted_attributes(fc_user, policy_class: Mypage::Fc::PasswordPolicy))
      postprocess_of_updated_password
      redirect_to mypage_fc_root_path
    else
      # :nocov:
      render :new, status: :unprocessable_entity
      # :nocov:
    end
  end

  def update
    if fc_user.update_with_password(permitted_attributes(fc_user, policy_class: Mypage::Fc::PasswordPolicy))
      bypass_sign_in(fc_user)

      render body: nil, status: :created, location: mypage_fc_settings_path
    else
      render :edit, status: :unprocessable_entity, layout: 'modal'
    end
  end

  private

  def fc_user
    @fc_user ||= ActiveType.cast(current_fc_user, Fc::ChangePassword::FcUser)
  end

  helper_method :fc_user

  def authorize_resource
    authorize fc_user, policy_class: Mypage::Fc::PasswordPolicy
  end

  def set_header_options
    header_options[:action] = :show
  end

  def reset_two_factor_authentication
    current_fc_user.skip_password_change_notification!
  end

  def postprocess_of_updated_password
    bypass_sign_in(fc_user)
    clear_request_reset_password
    reset_two_factor_authentication
  end
end
