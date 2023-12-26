# frozen_string_literal: true

# :reek:MissingSafeMethod
class LandingPagesController < ApplicationController
  before_action :perform_back, only: :update
  before_action :authenticate_finish!, only: :finish
  layout false

  def show
    render :show
  end

  def update
    if form.save
      session[:landing_pages_finish] = name_param
      redirect_to finish_landing_page_path(name: name_param)
    else
      render :show
    end
  end

  def finish
    render :finish
  end

  private

  # :nocov:
  def perform_back
    form.assign_attributes(signup_params)
    return unless params[:back]

    render :show
  end
  # :nocov:

  def landing_page
    @landing_page ||= LandingPage.find_by!(name: name_param)
  end

  def form
    @form ||= LandingPages::RegistrationForm.new(landing_page:, request:)
  end

  def session_id
    session.id
  end

  helper_method :landing_page, :form, :session_id

  def name_param
    params.fetch(:name, nil)
  end

  def pundit_params_for(_record)
    params.require(:fc_user)
  end

  def signup_params
    permitted_attributes(form, policy_class: LandingPagePolicy)
  end

  def _prefixes
    ["landing_pages/#{landing_page.id}_#{landing_page.lp_code}"] + super
  end

  def authenticate_finish!
    raise ActiveRecord::RecordNotFound if session[:landing_pages_finish] != name_param

    session.delete :landing_pages_finish
  end
end
