class AddLeadNoOnUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :lead_no, :string

    add_index :users, :lead_no, unique: true
  end
end
