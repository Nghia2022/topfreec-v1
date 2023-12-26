# frozen_string_literal: true

class Mypage::Fc::RegistrationsController < Mypage::Fc::BaseController
  include ResetPasswordFirstLogin

  layout 'application'

  skip_before_action :verify_registration_completed
  before_action :redirect_to_reset_password, if: :request_reset_password?
  before_action :redirect_to_mypage, if: :registration_completed?
  before_action :authorize_resource

  def show
    form.restore(fc_user.person)
  end

  def create
    form.assign_attributes(create_params)
    if form.save(current_fc_user)
      activate_tutorial
      redirect_to mypage_fc_root_path
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def fc_user
    @fc_user ||= current_fc_user.decorate
  end

  delegate :person, to: :fc_user, allow_nil: true

  def profile
    @profile ||= ProfileDecorator.decorate(person.to_sobject)
  end

  def form
    @form ||= Fc::MainRegistration::RegistrationForm.new
  end

  def create_params
    permitted_attributes(form, policy_class: Mypage::Fc::RegistrationPolicy)
  end

  def pundit_params_for(_record)
    params.require(:fc_user)
  end

  def authorize_resource
    authorize(form, nil, policy_class: Mypage::Fc::RegistrationPolicy)
  end

  def redirect_to_mypage
    redirect_to mypage_fc_root_path
  end

  def activate_tutorial
    cookies.permanent[:enable_tutorial] = '1'
  end

  helper_method :profile, :form, :fc_user

  concerning :Breadcrumbs do
    included do
      add_breadcrumb 'ログイン', ''
      add_breadcrumb '会員情報入力', ''
    end
  end
end
