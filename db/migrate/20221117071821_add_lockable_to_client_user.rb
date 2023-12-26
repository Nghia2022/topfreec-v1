class AddLockableToClientUser < ActiveRecord::Migration[6.0]
  def change
    change_table :client_users do |t|
      t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      t.datetime :locked_at
    end
  end
end
