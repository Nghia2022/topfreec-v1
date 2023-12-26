class AddContactSfidToFcUser < ActiveRecord::Migration[6.0]
  def change
    add_column :fc_users, :contact_sfid, :string
    add_index :fc_users, :contact_sfid, unique: true
  end
end
