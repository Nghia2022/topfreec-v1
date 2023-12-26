class AddMissingColumnsToDesiredConditions < ActiveRecord::Migration[6.0]
  def change
    remove_column :desired_conditions, :activity_status, :string
  end
end
