# frozen_string_literal: true

class Mypage::Fc::BaseController < Mypage::ApplicationController
  before_action :authenticate_fc_user!
  before_action :verify_registration_completed

  include TrackFieldsUpdatable

  add_breadcrumb 'マイページ', :mypage_root_path

  alias pundit_user current_fc_user

  delegate :registration_completed?, to: :current_fc_user

  private

  def verify_registration_completed
    redirect_to mypage_fc_registration_path unless current_fc_user.registration_completed?
  end
end
