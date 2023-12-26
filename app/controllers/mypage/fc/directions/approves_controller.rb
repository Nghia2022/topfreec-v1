# frozen_string_literal: true

class Mypage::Fc::Directions::ApprovesController < Mypage::Fc::BaseController
  include Fc::ManageDirection::DirectionApprovable

  before_action :authorize_direction

  def show
    render layout: 'modal'
  end

  def create
    if direction.approve_by_fc!(fc_user: current_fc_user, sf_contact:)
      redirect_to mypage_fc_directions_path, notice: '業務指示を確認しました'
    else
      redirect_with_alert
    end
  end

  rescue_from AASM::InvalidTransition, with: :redirect_with_alert

  private

  def authorize_direction
    authorize direction, policy_class: Mypage::Fc::Directions::ApprovesPolicy
  end

  def redirect_with_alert
    redirect_to mypage_fc_directions_path, alert: '業務指示を確認できませんでした'
  end
end
