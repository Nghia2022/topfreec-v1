class CreateDesiredOccupations < ActiveRecord::Migration[6.0]
  def change
    create_table :desired_occupations do |t|
      t.integer :occupation_id
      t.string :desired_condition_id
      t.timestamps

      t.index :occupation_id
      t.index :desired_condition_id
    end
  end
end
