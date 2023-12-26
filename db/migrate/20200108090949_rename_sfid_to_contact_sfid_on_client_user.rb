class RenameSfidToContactSfidOnClientUser < ActiveRecord::Migration[6.0]
  def change
    rename_column :client_users, :sfid, :contact_sfid
  end
end
