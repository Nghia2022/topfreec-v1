class RenameColumnInProjectCategoryMetum < ActiveRecord::Migration[6.0]
  def change
    rename_column :project_category_meta, :keyword, :keywords
  end
end
