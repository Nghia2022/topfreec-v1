class ChangeNotNullForIsDeletedOnProjects < ActiveRecord::Migration[6.0]
  def up
    change_column_null :projects, :is_deleted, false, false
    change_column :projects, :is_deleted, :boolean, default: false
  end

  def down
    change_column_null :projects, :is_deleted, true, nil
    change_column :projects, :is_deleted, :boolean, default: nil
  end
end
