class FillProjectCategoryMeta < ActiveRecord::Migration[6.0]
  def change
    Rake::Task['oneshot:create_project_category_meta'].invoke
  end
end
