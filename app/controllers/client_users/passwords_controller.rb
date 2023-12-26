# frozen_string_literal: true

class ClientUsers::PasswordsController < Devise::PasswordsController
  include ResetPassword::Controller::ResetPasswordTokenAssertable

  before_action :set_header_options

  layout 'welcome'

  def new
    super

    resource.errors.add(:base, flash[:alert]) if flash.key?(:alert)
  end

  def create
    super do |resource|
      respond_with(resource) and return if resource.errors.added?(:email, :blank)
    end
  end

  def guide; end

  protected

  def set_header_options
    header_options[:action] = :corp_top
  end

  def resource_class
    Client::ResetPassword::ClientUser
  end

  def after_sending_reset_password_instructions_path_for(_resource_name)
    guide_client_user_password_path
  end

  concerning :Breadcrumbs do
    def build_breadcrumbs(options)
      @breadcrumbs_on_rails = [] # FIXME: updateでエラーになったとき2回呼ばれるのでリセットする
      add_breadcrumb 'TOP', :root_path

      case options[:template]
      when 'edit', 'update'
        add_breadcrumb 'お取引企業様 パスワード設定', ''
      else
        add_breadcrumb 'お取引企業様 パスワード発行', :new_client_user_password_path
      end
    end
  end
end
