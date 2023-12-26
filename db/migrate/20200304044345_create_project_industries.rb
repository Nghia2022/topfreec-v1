class CreateProjectIndustries < ActiveRecord::Migration[6.0]
  def change
    create_table :project_industries do |t|
      t.integer :industry_id
      t.string :project_id
      t.timestamps

      t.index :industry_id
      t.index :project_id
    end
  end
end
