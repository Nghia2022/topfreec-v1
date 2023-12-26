class RenameOpportunitiesToProjects < ActiveRecord::Migration[6.0]
  def up
    rename_table :opportunities, :projects
  end
  
  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
