class DropOperationResults < ActiveRecord::Migration[6.0]
  def up
    drop_table :operation_results
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
