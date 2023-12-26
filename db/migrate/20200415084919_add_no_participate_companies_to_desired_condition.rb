class AddNoParticipateCompaniesToDesiredCondition < ActiveRecord::Migration[6.0]
  def change
    add_column :desired_conditions, :no_participate_company_names, :text
  end
end
