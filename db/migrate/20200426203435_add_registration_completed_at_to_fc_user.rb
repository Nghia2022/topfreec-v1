class AddRegistrationCompletedAtToFcUser < ActiveRecord::Migration[6.0]
  def change
    add_column :fc_users, :registration_completed_at, :datetime
  end
end
