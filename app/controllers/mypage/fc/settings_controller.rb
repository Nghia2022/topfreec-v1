# frozen_string_literal: true

class Mypage::Fc::SettingsController < Mypage::Fc::BaseController
  before_action :authorize_resource

  def index; end

  private

  delegate :person, to: :fc_user, allow_nil: true

  def fc_user
    @fc_user ||= current_fc_user
  end

  def contact
    @contact ||= fc_user.contact
  end

  def profile
    @profile ||= ProfileDecorator.decorate(contact.to_sobject)
  end
  helper_method :profile

  def contact_for_ml_reject
    @contact_for_ml_reject ||= contact.decorate
  end
  helper_method :contact_for_ml_reject

  def authorize_resource
    # TODO* 設定を保存するオブジェクトを実装する
    authorize nil, policy_class: Mypage::Fc::SettingPolicy
  end

  def notice_for_resume
    notice = flash[:notice]
    return unless notice&.match?('レジュメ')

    # :nocov:
    notice
    # :nocov:
  end
  helper_method :notice_for_resume

  concerning :Breadcrumbs do
    included do
      add_breadcrumb '設定', :mypage_fc_settings_path
    end
  end
end
