class AddOriginalSecretToOauthApplication < ActiveRecord::Migration[6.0]
  MigrationApplication = Class.new(ApplicationRecord) do
    self.table_name = :oauth_applications
  end

  def change
    add_column :oauth_applications, :original_secret, :string

    MigrationApplication.reset_column_information
    MigrationApplication.find_each do |application|
      application.original_secret = application.secret
      application.save!
    end
  end
end
