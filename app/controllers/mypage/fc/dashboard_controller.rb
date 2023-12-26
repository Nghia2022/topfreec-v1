# frozen_string_literal: true

class Mypage::Fc::DashboardController < Mypage::Fc::BaseController
  include TopicsDisplayable
  include ProjectSearchable
  include Fc::ManageDirection::DirectionApprovable

  before_action :authorize_resource

  alias pundit_user current_fc_user

  def index
    @pickup_projects = policy_scope(Project).decorate
    @new_arrival_projects = policy_scope(Project).decorate
    @projects_featured = Project.published.featured_order.limit(8).decorate
  end

  private

  delegate :person, to: :fc_user, allow_nil: true

  def authorize_resource
    authorize nil, policy_class: Mypage::Fc::DashboardPolicy
  end

  def fc_user
    @fc_user ||= current_fc_user
  end

  def contact
    @contact ||= fc_user.contact
  end

  def account
    @account ||= fc_user.account.decorate
  end
  helper_method :account

  def pending_directions_count
    @pending_directions_count ||= direction_scope.waiting_for_fc.count
  end
  helper_method :pending_directions_count

  def recommended_projects
    @recommended_projects ||= Fc::Recommended::ProjectsQuery.call(
      relation: policy_scope(Project),
      contact:  contact.decorate
    ).new_arrival.limit(Fc::Recommended::ProjectsQuery.display_limit).decorate
  end

  helper_method :recommended_projects
end
