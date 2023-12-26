class RenameIsOpenedColumnToOperationResult < ActiveRecord::Migration[6.0]
  def change
    rename_column :operation_results, :is_opened, :is_published
  end
end
