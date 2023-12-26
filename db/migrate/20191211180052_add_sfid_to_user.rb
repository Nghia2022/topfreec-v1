class AddSfidToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :sfid, :string
    add_index :users, :sfid
  end
end
