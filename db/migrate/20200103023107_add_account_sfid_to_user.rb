class AddAccountSfidToUser < ActiveRecord::Migration[6.0]
  def change
    change_table :users do |t|
      t.string :account_sfid
      t.datetime :activated_at

      t.index :account_sfid
    end
  end
end
