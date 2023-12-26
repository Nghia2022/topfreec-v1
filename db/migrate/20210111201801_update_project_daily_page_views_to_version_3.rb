# frozen_string_literal: true

class UpdateProjectDailyPageViewsToVersion3 < ActiveRecord::Migration[6.0]
  def change
    update_view :project_daily_page_views, version: 3, revert_to_version: 2, materialized: true
  end
end
