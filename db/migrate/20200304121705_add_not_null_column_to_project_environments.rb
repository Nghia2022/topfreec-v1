class AddNotNullColumnToProjectEnvironments < ActiveRecord::Migration[6.0]
  def change
    change_column_null :project_environments, :project_id, false
    change_column_null :project_environments, :environment_id, false
  end
end
