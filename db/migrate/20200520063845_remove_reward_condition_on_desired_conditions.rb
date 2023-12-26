class RemoveRewardConditionOnDesiredConditions < ActiveRecord::Migration[6.0]
  def change
    remove_column :desired_conditions, :reward_condition, :string
    remove_column :desired_conditions, :reward_max, :string
  end
end
