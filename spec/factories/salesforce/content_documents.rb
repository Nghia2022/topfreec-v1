# frozen_string_literal: true

FactoryBot.define do
  factory :sf_content_document, class: 'Salesforce::ContentDocument' do
    attributes { { type: 'ContentDocument' } }
    add_attribute(:Title) { Faker::File.file_name }
    add_attribute(:LastModifiedDate) { Time.current.iso8601 }

    after(:stub) { |sf_user| sf_user.Id = FactoryBot.generate :sfid }
  end
end
