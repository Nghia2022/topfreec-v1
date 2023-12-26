class AddUniqueIndexsToProjectRelations < ActiveRecord::Migration[6.0]
  def change
    add_index :project_environments, %i[project_id environment_id], unique: true
    add_index :project_industries, %i[project_id industry_id], unique: true
    add_index :project_occupations, %i[project_id occupation_id], unique: true
    add_index :project_tags, %i[project_id tag_id], unique: true
  end
end
