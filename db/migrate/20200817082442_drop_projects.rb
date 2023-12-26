class DropProjects < ActiveRecord::Migration[6.0]
  def up
    drop_table :projects
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
