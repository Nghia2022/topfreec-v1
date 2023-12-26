# frozen_string_literal: true

class AggregatePageViewsJob < ApplicationJob
  queue_as :default

  def perform(arg)
    send("refresh_project_#{arg}_page_views")
  end

  private

  def refresh_project_daily_page_views
    ProjectDailyPageView.refresh
  end

  def refresh_project_weekly_page_views
    ProjectWeeklyPageView.refresh(concurrently: false)
  end

  def refresh_project_monthly_page_views
    ProjectMonthlyPageView.refresh(concurrently: false)
  end
end
