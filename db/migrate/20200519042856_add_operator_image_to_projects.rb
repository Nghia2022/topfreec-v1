class AddOperatorImageToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :operator_image, :string
  end
end
