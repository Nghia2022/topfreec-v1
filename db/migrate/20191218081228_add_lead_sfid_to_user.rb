class AddLeadSfidToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :lead_sfid, :string
    add_index :users, :lead_sfid
  end
end
