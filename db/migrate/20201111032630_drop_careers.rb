class DropCareers < ActiveRecord::Migration[6.0]
  def up
    drop_table :careers
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
