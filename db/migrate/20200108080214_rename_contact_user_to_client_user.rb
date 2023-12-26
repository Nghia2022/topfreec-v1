class RenameContactUserToClientUser < ActiveRecord::Migration[6.0]
  def change
    rename_table :contact_users, :client_users
  end
end
