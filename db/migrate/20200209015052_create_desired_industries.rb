class CreateDesiredIndustries < ActiveRecord::Migration[6.0]
  def change
    create_table :desired_industries do |t|
      t.integer :industry_id
      t.string :desired_condition_id
      t.timestamps

      t.index :industry_id
      t.index :desired_condition_id
    end
  end
end
