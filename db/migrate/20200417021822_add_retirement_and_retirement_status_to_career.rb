class AddRetirementAndRetirementStatusToCareer < ActiveRecord::Migration[6.0]
  def change
    add_column :careers, :retirement, :string
    add_column :careers, :retirement_status, :string
  end
end
