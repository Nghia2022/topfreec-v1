# frozen_string_literal: true

class Mypage::Client::Directions::RejectsController < Mypage::Client::BaseController
  include Client::ManageDirection::DirectionApprovable

  before_action :authorize_direction

  def show
    render layout: 'modal'
  end

  def create
    if direction.reject_by_client!(params: direction_params, client_user: current_client_user, sf_contact:)
      redirect_to mypage_client_directions_path, notice: '業務指示を保留しました'
    else
      render :show, status: :unprocessable_entity, layout: 'modal'
    end
  end

  private

  def direction_params
    permitted_attributes(direction, nil, policy_class: Mypage::Client::Directions::RejectsPolicy)
  end

  def authorize_direction
    authorize direction, policy_class: Mypage::Client::Directions::RejectsPolicy
  end
end
