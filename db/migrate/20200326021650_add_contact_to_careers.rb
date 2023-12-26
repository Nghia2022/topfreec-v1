class AddContactToCareers < ActiveRecord::Migration[6.0]
  def change
    remove_index :careers, :account_sfid
    remove_column :careers, :account_sfid, :string
    add_column :careers, :contact_sfid, :string
    add_index :careers, :contact_sfid
  end
end
