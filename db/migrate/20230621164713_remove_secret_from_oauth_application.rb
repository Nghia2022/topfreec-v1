class RemoveSecretFromOauthApplication < ActiveRecord::Migration[6.0]
  def change
    remove_column :oauth_applications, :secret, :string
  end
end
