class DropProjectOccupations < ActiveRecord::Migration[6.0]
  def up
    drop_table :project_occupations
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
