# frozen_string_literal: true

class Mypage::Client::PasswordsController < Mypage::Client::BaseController
  before_action :authorize_resource

  def edit
    render layout: 'modal'
  end

  def update
    if client_user.update_with_password(permitted_attributes(client_user, policy_class: Mypage::Client::PasswordPolicy))
      bypass_sign_in(client_user)
      redirect_to mypage_client_settings_path
    else
      render :edit, status: :unprocessable_entity, layout: 'modal'
    end
  end

  private

  def client_user
    @client_user ||= ActiveType.cast(current_client_user, Client::ChangePassword::ClientUser)
  end

  helper_method :client_user

  def authorize_resource
    authorize client_user, policy_class: Mypage::Client::PasswordPolicy
  end
end
