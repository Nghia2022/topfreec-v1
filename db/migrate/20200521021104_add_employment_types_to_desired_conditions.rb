class AddEmploymentTypesToDesiredConditions < ActiveRecord::Migration[6.0]
  def change
    rename_column :desired_conditions, :business_forms, :business_form
    add_column :desired_conditions, :employment_types, :string
  end
end
