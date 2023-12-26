class UpdateProjectDailyPageViewsToVersion2 < ActiveRecord::Migration[6.0]
  def change
    update_view :project_daily_page_views, version: 2, revert_to_version: 1, materialized: true
  end
end
