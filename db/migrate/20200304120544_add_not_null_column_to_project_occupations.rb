class AddNotNullColumnToProjectOccupations < ActiveRecord::Migration[6.0]
  def change
    change_column_null :project_occupations, :project_id, false
    change_column_null :project_occupations, :occupation_id, false
  end
end
