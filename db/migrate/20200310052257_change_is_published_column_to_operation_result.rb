class ChangeIsPublishedColumnToOperationResult < ActiveRecord::Migration[6.0]
  def change
    remove_column :operation_results, :is_published
    add_column :operation_results, :published_at, :datetime
  end
end
