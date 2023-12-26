class AddAttrEncryptedToOauthApplication < ActiveRecord::Migration[6.0]
  def change
    add_column :oauth_applications, :encrypted_secret, :string
    add_column :oauth_applications, :encrypted_secret_iv, :string

    Oauth::Application.reset_column_information
    Oauth::Application.find_each do |application|
      application.secret = application.original_secret
      application.save!
    end
  end
end
