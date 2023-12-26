# frozen_string_literal: true

class DropDesiredCondition < ActiveRecord::Migration[6.0]
  def up
    drop_table :desired_occupations
    drop_table :desired_industries
    drop_table :expert_industries
    drop_table :desired_conditions
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
