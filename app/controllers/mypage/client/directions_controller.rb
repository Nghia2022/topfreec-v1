# frozen_string_literal: true

class Mypage::Client::DirectionsController < Mypage::Client::BaseController
  include Client::ManageDirection::DirectionApprovable

  before_action :authorize_directions, only: %i[index]

  def index
    touch_directions
  end

  private

  def directions
    @directions ||= direction_scope.includes(project: :fc_account)
                                   .filter_by_status(params[:status] || 'waiting_for_client')
                                   .latest_order
                                   .page(page_param)
                                   .decorate
  end

  helper_method :directions

  def authorize_directions
    authorize directions, policy_class: Mypage::Client::DirectionPolicy
  end

  def touch_directions
    directions.open_unread
  end

  concerning :Breadcrumbs do
    def build_breadcrumbs(_options)
      add_breadcrumb '業務指示確認', :mypage_client_directions_path
    end
  end
end
