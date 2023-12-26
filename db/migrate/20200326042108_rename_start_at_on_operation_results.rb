class RenameStartAtOnOperationResults < ActiveRecord::Migration[6.0]
  def change
    rename_column :operation_results, :start_at, :joined
    rename_column :operation_results, :end_at, :left
  end
end
