class CreateDesiredConditions < ActiveRecord::Migration[6.0]
  def change
    create_table :desired_conditions, id: false do |t|
      t.string :sfid, primary_key: true
      t.string :account_sfid
      t.string :activity_status
      t.string :start_timing
      t.string :occupations, limit: 1024
      t.string :company_sizes
      t.string :work_locations
      t.string :reward_condition
      t.string :reward_min
      t.string :reward_max
      t.string :occupancy_rate
      t.string :business_forms
      t.text :requests
      t.timestamps

      t.index :account_sfid
    end
  end
end
