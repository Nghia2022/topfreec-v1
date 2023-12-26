class CreateProjectEnvironments < ActiveRecord::Migration[6.0]
  def change
    create_table :project_environments do |t|
      t.integer :environment_id
      t.string :project_id
      t.timestamps

      t.index :environment_id
      t.index :project_id
    end
  end
end
