class RenameUserToFcUser < ActiveRecord::Migration[6.0]
  def change
    rename_table :users, :fc_users
  end
end
