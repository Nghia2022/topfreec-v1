class AddContactToEducations < ActiveRecord::Migration[6.0]
  def change
    remove_index :educations, :account_sfid
    remove_column :educations, :account_sfid, :string
    add_column :educations, :contact_sfid, :string
    add_index :educations, :contact_sfid
  end
end
