class DropUnusedTables < ActiveRecord::Migration[6.0]
  def up
    drop_table :tags
    drop_table :environments
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
