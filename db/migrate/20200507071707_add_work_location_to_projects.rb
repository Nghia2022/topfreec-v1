class AddWorkLocationToProjects < ActiveRecord::Migration[6.0]
  def change
    remove_column :projects, :prefecture, :integer
    add_column :projects, :work_location, :string
  end
end
