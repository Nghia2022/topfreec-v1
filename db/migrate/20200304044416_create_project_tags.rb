class CreateProjectTags < ActiveRecord::Migration[6.0]
  def change
    create_table :project_tags do |t|
      t.integer :tag_id
      t.string :project_id
      t.timestamps

      t.index :tag_id
      t.index :project_id
    end
  end
end
