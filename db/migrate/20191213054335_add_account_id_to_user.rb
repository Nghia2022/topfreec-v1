class AddAccountIdToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :account_id, :integer
    add_index :users, :account_id
    remove_column :users, :sfid
  end
end
