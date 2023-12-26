# frozen_string_literal: true

# disable :reek:InstanceVariableAssumption
class FcUsers::SessionsController < Devise::SessionsController
  layout 'welcome'
  prepend_before_action :allow_params_authentication!, only: %i[create]

  def new
    store_location_for(:fc_user, return_url)
    super
  end

  # POST /resource/sign_in
  # rubocop:disable Metrics/AbcSize
  def create
    @fc_user = resource_class.new(sign_in_params)
    unless verify_recaptcha(model: @fc_user, action: 'login')
      warden.lock!
      flash[:alert] = @fc_user.errors[:base].first
      render :new
      return
    end

    self.resource = warden.authenticate!(auth_options)
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    respond_with resource, location: after_sign_in_path_for(resource)
  rescue ArgumentError => e
    # :nocov:
    render :new, alert: '認証コードを送信出来ませんでした'
    # :nocov:
  end
  # rubocop:enable Metrics/AbcSize

  protected

  delegate :referer, to: :request

  def after_sign_in_path_for(_resource)
    stored = stored_location_for(:fc_user) unless current_fc_user.fc_company?
    stored || mypage_fc_root_path
  end

  def return_url
    return unless referer.to_s.gsub(root_url, '').starts_with?(/project|job/)

    referer
  end

  concerning :Breadcrumbs do
    def build_breadcrumbs(_options)
      add_breadcrumb 'TOP', :root_path
      add_breadcrumb 'ログイン', :new_fc_user_session_path
    end
  end
end
