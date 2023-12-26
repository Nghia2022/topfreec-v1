class AddAccountSfidToClientUser < ActiveRecord::Migration[6.0]
  def change
    change_table :client_users do |t|
      t.string :account_sfid

      t.index :account_sfid
    end
  end
end
