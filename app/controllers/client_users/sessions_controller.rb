# frozen_string_literal: true

# disable :reek:InstanceVariableAssumption
class ClientUsers::SessionsController < Devise::SessionsController
  layout 'welcome'
  before_action :set_header_options
  before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # rubocop:disable Metrics/AbcSize
  def create
    @client_user = resource_class.new(sign_in_params)
    unless verify_recaptcha(model: @client_user, action: 'login')
      warden.lock!
      flash[:alert] = @client_user.errors[:base].first
      render :new
      return
    end

    self.resource = warden.authenticate!(auth_options)
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    respond_with resource, location: after_sign_in_path_for(resource)
  end
  # rubocop:enable Metrics/AbcSize

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  protected

  def set_header_options
    header_options[:action] = :corp_top
  end

  def after_sign_in_path_for(_resource)
    mypage_client_root_path
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:recaptcha_token])
  end

  concerning :Breadcrumbs do
    included do
      add_breadcrumb 'TOP', :root_path
      add_breadcrumb 'お取引企業様 ログイン', :new_client_user_session_path
    end
  end
end
