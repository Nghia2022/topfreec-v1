# frozen_string_literal: true

class UpdateProjectDailyPageViewsToVersion4 < ActiveRecord::Migration[6.0]
  def change
    update_view :project_daily_page_views, version: 4, revert_to_version: 3, materialized: true
  end
end
