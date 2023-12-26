# frozen_string_literal: true

class Mypage::Client::DashboardController < Mypage::Client::BaseController
  before_action :authorize_resource

  def index
    redirect_to mypage_client_directions_path
  end

  private

  def authorize_resource
    authorize nil, policy_class: Mypage::Client::DashboardPolicy
  end
end
