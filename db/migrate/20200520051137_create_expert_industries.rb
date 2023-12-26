class CreateExpertIndustries < ActiveRecord::Migration[6.0]
  def up
    drop_table :expert_occupations

    create_table :expert_industries do |t|
      t.integer :industry_id
      t.string :desired_condition_id
      t.timestamps

      t.index :industry_id
      t.index :desired_condition_id
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
