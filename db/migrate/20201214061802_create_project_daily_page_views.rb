class CreateProjectDailyPageViews < ActiveRecord::Migration[6.0]
  def change
    create_view :project_daily_page_views, materialized: true
    add_index :project_daily_page_views, :pv
    add_index :project_daily_page_views, :project_id, unique: true
  end
end
