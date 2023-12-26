class AddColumnsToEducations < ActiveRecord::Migration[6.0]
  def change
    add_column :educations, :school_type, :string
    add_column :educations, :degree, :string
    add_column :educations, :degree_name, :string
    add_column :educations, :major, :string
  end
end
