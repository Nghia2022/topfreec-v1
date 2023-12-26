# frozen_string_literal: true

class ProjectSearchQuery
  include Query

  def initialize(form:, user:, relation: Project.published)
    @relation = relation
    @form = form
    @user = user
  end

  attr_reader :relation, :form, :user

  # rubocop:disable Metrics/AbcSize
  def call
    relation.with_keyword(form.keyword)
            .with_compensations(form.compensation_ranges)
            .with_experience_categories(form.categories&.reject(&:blank?))
            .with_work_locations(form.work_locations&.reject(&:blank?))
            .with_work_options(form.work_options&.reject(&:blank?))
            .with_occupancy_rate_mins(occupancy_rate_mins)
            .with_occupancy_rate_maxs(occupancy_rate_maxs)
            .with_period_from(to_all_month(form.period_from))
            .with_period_to(to_all_month(form.period_to))
            .without_closed(recruiting)
            .without_stopped(recruiting, user)
            .without_entered(user)
            .merge(order_scope)
  end
  # rubocop:enable Metrics/AbcSize

  private

  delegate :recruiting, to: :form

  def order_scope
    return relation.sort_compensation if form.sort == 'compensation'

    relation.latest_order
  end

  def to_all_month(year_month_string)
    return unless year_month_string.to_s.match?(/\d{4}-\d{2}/)

    Date.parse("#{year_month_string}-01").all_month
  end

  def occupancy_rate_mins
    min = form.occupancy_rate_mins.to_a.compact_blank.first.to_i
    return if min.zero?

    [nil, *Project::OccupancyRateMin.pluck(:value).map(&:to_i).select { |value| value >= min }]
  end

  def occupancy_rate_maxs
    max = form.occupancy_rate_maxs.to_a.compact_blank.first.to_i
    return if max.zero?

    [nil, *Project::OccupancyRateMax.pluck(:value).map(&:to_i).select { |value| value <= max }]
  end
end
