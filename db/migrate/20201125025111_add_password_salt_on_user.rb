class AddPasswordSaltOnUser < ActiveRecord::Migration[6.0]
  def change
    change_table :fc_users do |t|
      t.string :password_salt
    end

    change_table :client_users do |t|
      t.string :password_salt
    end

    reversible do |dir|
      dir.up do
        [FcUser, ClientUser].each do |klass|
          update_password_salt(klass)
        end
      end
    end
  end

  def update_password_salt(klass)
    klass.reset_column_information

    klass.find_each do |user|
      if user.encrypted_password
        salt = user.encrypted_password.split('$')[2]
        user.update(password_salt: salt)
      end
    end
  end
end
