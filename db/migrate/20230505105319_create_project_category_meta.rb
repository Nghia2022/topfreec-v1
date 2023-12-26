class CreateProjectCategoryMeta < ActiveRecord::Migration[6.0]
  def change
    create_table :project_category_meta do |t|
      t.string :slug, null: false, index: { unique: true } 
      t.string :work_category_main, null: false
      t.string :work_category_sub
      t.string :title
      t.text :description
      t.string :keyword

      t.timestamps
    end
  end
end
