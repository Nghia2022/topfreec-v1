# frozen_string_literal: true

namespace :oneshot do
  task create_project_category_meta: :environment do
    Kernel.open(Rails.root.join('db/fixtures/project_category_meta.yml'), 'r') do |f|
      ProjectCategoryMetum.create(YAML.safe_load(f))
    end
  end
end
