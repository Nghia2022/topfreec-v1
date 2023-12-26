class AddNotNullColumnToProjectIndustries < ActiveRecord::Migration[6.0]
  def change
    change_column_null :project_industries, :project_id, false
    change_column_null :project_industries, :industry_id, false
  end
end
