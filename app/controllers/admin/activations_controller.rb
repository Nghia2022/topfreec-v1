# frozen_string_literal: true

class Admin::ActivationsController < Admin::ApplicationController
  def index; end

  def edit; end

  # :reek:DuplicateMethodCall
  def update
    if fc_user.send_activation activate_params[:contact_sfid]
      redirect_to admin_activations_path, notice: 'アクティベーションメールを送信しました'
    else
      # :nocov:
      render :edit
      # :nocov:
    end
  rescue Fc::UserActivation::ContactNotFound
    render :edit
  end

  private

  def unactivated_users
    @unactivated_users ||= Fc::UserActivation::FcUser.unactivated.page(page_param)
  end
  helper_method :unactivated_users

  def fc_user
    @fc_user ||= unactivated_users.find(params[:id])
  end
  helper_method :fc_user

  def activate_params
    params.require(:fc_user).permit(:contact_sfid)
  end
end
