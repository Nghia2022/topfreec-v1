# frozen_string_literal: true

# :reek:MissingSafeMethod
class FcUsers::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :perform_back, only: [:create]
  before_action :authenticate_thanks!, only: :thanks
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # rubocop:disable Metrics/AbcSize
  def create
    resource.skip_confirmation_notification!

    if resource.save
      set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
      expire_data_after_sign_in!
      session[:registered_lead_sfid] = resource.lead_sfid
      redirect_to after_inactive_sign_up_path_for(resource)
    else
      set_minimum_password_length
      if resource.confirming?
        clean_up_passwords resource
        render 'confirm'
      else
        render 'new'
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  def thanks; end

  protected

  def perform_back
    build_resource(sign_up_params)
    return unless params[:back]

    # :nocov:
    resource.reset_confirming
    render :new
    # :nocov:
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[last_name first_name last_name_kana first_name_kana phone work_location1 work_location2 work_location3 confirming])
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  def after_inactive_sign_up_path_for(_resource)
    thanks_fc_user_registration_path
  end

  def build_resource(hash = {})
    self.resource = Fc::UserRegistration::FcUser.new_with_session(hash, session).tap do |fc_user|
      fc_user.session_id = request.session.id
      fc_user.user_agent = request.user_agent
    end
  end

  concerning :Breadcrumbs do
    def build_breadcrumbs(options)
      add_breadcrumb 'TOP', :root_path

      case options[:template]
      when 'new'
        add_breadcrumb 'ログイン', :new_fc_user_session_path
        add_breadcrumb '会員情報入力', :new_fc_user_registration_path
      when 'confirm'
        add_breadcrumb '会員情報 確認', ''
      when 'thanks'
        add_breadcrumb '会員情報 完了'
      end
    end
  end

  def authenticate_thanks!
    raise ActiveRecord::RecordNotFound unless registered_lead_sfid

    session.delete :registered_lead_sfid
  end

  def registered_lead_sfid
    @registered_lead_sfid ||= session[:registered_lead_sfid]
  end
  helper_method :registered_lead_sfid
end
