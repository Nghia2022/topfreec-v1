class AddContactToOperationResults < ActiveRecord::Migration[6.0]
  def change
    remove_index :operation_results, :account_sfid
    remove_column :operation_results, :account_sfid, :string
    add_column :operation_results, :contact_sfid, :string
    add_index :operation_results, :contact_sfid
  end
end
