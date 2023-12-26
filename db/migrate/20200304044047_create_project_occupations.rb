class CreateProjectOccupations < ActiveRecord::Migration[6.0]
  def change
    create_table :project_occupations do |t|
      t.integer :occupation_id
      t.string :project_id
      t.timestamps

      t.index :occupation_id
      t.index :project_id
    end
  end
end
