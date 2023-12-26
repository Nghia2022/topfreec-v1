# frozen_string_literal: true

namespace :seed do
  namespace :picklist do
    task dump: :environment do
      model = ENV.fetch('MODEL', nil)

      klass = model.constantize
      filename = Rails.root.join('db/fixtures/test', "#{klass.model_name.singular}.rb").to_s
      SeedFu::Writer.write(filename, class_name: 'Salesforce::PicklistValue', constraints: %i[sobject field label]) do |writer|
        klass.all.each do |record|
          writer << record.attributes.except('id', 'updated_at')
        end
      end
    end
  end

  namespace :work_category do
    task dump: :environment do
      filename = Rails.root.join('db/fixtures/test/work_category.rb').to_s
      SeedFu::Writer.write(filename, class_name: 'WorkCategory', constraints: %i[name]) do |writer|
        WorkCategory.all.each do |record|
          writer << record.attributes.except('id', 'createddate', 'systemmodstamp')
        end
      end
    end
  end
end
