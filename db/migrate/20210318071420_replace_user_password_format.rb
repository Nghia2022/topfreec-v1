class ReplaceUserPasswordFormat < ActiveRecord::Migration[6.0]
  def change
    reversible do |dir|
      dir.up do
        UserPasswordMigrator.migrate
      end
    end
  end
end
