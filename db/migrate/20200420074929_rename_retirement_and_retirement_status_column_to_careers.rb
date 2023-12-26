class RenameRetirementAndRetirementStatusColumnToCareers < ActiveRecord::Migration[6.0]
  def change
    rename_column :careers, :retirement, :left
    rename_column :careers, :retirement_status, :left_status
  end
end
