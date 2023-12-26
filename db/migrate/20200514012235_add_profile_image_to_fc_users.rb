class AddProfileImageToFcUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :fc_users, :profile_image, :string
  end
end
