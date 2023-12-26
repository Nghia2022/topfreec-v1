class AddUserAgentToClientUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :client_users, :user_agent, :string, null: false, default: ''
  end
end
