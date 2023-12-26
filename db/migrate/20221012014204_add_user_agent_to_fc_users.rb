class AddUserAgentToFcUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :fc_users, :user_agent, :string, null: false, default: ''
  end
end
