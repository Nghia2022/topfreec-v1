class AddActivationTokenToFcUser < ActiveRecord::Migration[6.0]
  def change
    add_column :fc_users, :activation_token, :string
    add_index :fc_users, :activation_token, unique: true
  end
end
