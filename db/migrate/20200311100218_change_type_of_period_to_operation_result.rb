class ChangeTypeOfPeriodToOperationResult < ActiveRecord::Migration[6.0]
  def change
    reversible do |dir|
      dir.up do
        change_column :operation_results, :start_at, :string
        change_column :operation_results, :end_at, :string
      end

      dir.down do
        raise ActiveRecord::IrreversibleMigration
      end
    end
  end
end
