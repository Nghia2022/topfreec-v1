class AddNotNullColumnToProjectTags < ActiveRecord::Migration[6.0]
  def change
    change_column_null :project_tags, :project_id, false
    change_column_null :project_tags, :tag_id, false
  end
end
