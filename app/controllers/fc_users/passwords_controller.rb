# frozen_string_literal: true

class FcUsers::PasswordsController < Devise::PasswordsController
  include ResetPassword::Controller::ResetPasswordTokenAssertable

  layout 'welcome'

  # GET /resource/password/new
  def new
    super

    resource.errors.add(:base, flash[:alert]) if flash.key?(:alert)
  end

  # POST /resource/password
  def create
    super do |resource|
      respond_with(resource) and return if resource.errors.added?(:email, :blank)
    end
  end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  # def update
  #   super
  # end

  protected

  def resource_class
    Fc::ResetPassword::FcUser
  end

  # The path used after sending reset password instructions
  def after_sending_reset_password_instructions_path_for(_resource_name)
    guide_fc_user_password_path
  end

  concerning :Breadcrumbs do
    def build_breadcrumbs(options)
      @breadcrumbs_on_rails = [] # FIXME: updateでエラーになったとき2回呼ばれるのでリセットする

      add_breadcrumb 'TOP', :root_path

      case options[:template]
      when 'edit', 'update'
        add_breadcrumb 'パスワード設定', ''
      else
        add_breadcrumb 'パスワード発行', :new_fc_user_password_path
      end
    end
  end
end
