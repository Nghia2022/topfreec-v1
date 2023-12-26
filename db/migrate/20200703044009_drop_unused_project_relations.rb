class DropUnusedProjectRelations < ActiveRecord::Migration[6.0]
  def up
    drop_table :project_tags
    drop_table :project_environments
    drop_table :project_industries
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
