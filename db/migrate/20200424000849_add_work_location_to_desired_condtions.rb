class AddWorkLocationToDesiredCondtions < ActiveRecord::Migration[6.0]
  def change
    remove_column :desired_conditions, :work_locations, :string
    add_column :desired_conditions, :work_location1, :string
    add_column :desired_conditions, :work_location2, :string
    add_column :desired_conditions, :work_location3, :string
  end
end
