class AddSfidOnContactUser < ActiveRecord::Migration[6.0]
  def change
    add_column :contact_users, :sfid, :string, index: true
  end
end
