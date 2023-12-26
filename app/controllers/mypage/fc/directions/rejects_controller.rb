# frozen_string_literal: true

class Mypage::Fc::Directions::RejectsController < Mypage::Fc::BaseController
  include Fc::ManageDirection::DirectionApprovable

  before_action :authorize_direction

  def show
    render layout: 'modal'
  end

  def create
    if direction.reject_by_fc!(params: direction_params, fc_user: current_fc_user, sf_contact:)
      redirect_to mypage_fc_directions_path, notice: '業務指示を保留しました'
    else
      render_error
    end
  end

  rescue_from AASM::InvalidTransition, with: :render_error

  private

  def direction_params
    permitted_attributes(direction, nil, policy_class: Mypage::Fc::Directions::RejectsPolicy)
  end

  def authorize_direction
    authorize direction, policy_class: Mypage::Fc::Directions::RejectsPolicy
  end

  def render_error
    render :show, status: :unprocessable_entity, layout: 'modal'
  end
end
