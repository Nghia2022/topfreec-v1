# frozen_string_literal: true

class Mypage::Client::Directions::ApprovesController < Mypage::Client::BaseController
  include Client::ManageDirection::DirectionApprovable

  before_action :authorize_direction

  def show
    render layout: 'modal'
  end

  def create
    if direction.approve_by_client!(client_user: current_client_user, sf_contact:)
      redirect_to mypage_client_directions_path, notice: '業務指示を確認しました'
    else
      # :nocov:
      redirect_to mypage_client_directions_path, alert: '業務指示を確認できませんでした'
      # :nocov:
    end
  end

  private

  def authorize_direction
    authorize direction, policy_class: Mypage::Client::Directions::ApprovesPolicy
  end
end
