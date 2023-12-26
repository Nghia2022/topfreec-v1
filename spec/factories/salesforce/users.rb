# frozen_string_literal: true

FactoryBot.define do
  factory :sf_user, class: 'Salesforce::User' do
    attributes { { type: 'User' } }
    add_attribute(:Email) { Faker::Internet.email }
    add_attribute(:LastName) { Faker::Japanese::Name.last_name }
    add_attribute(:FirstName) { Faker::Japanese::Name.first_name }

    after(:stub) { |sf_user| sf_user.Id = FactoryBot.generate :sfid }
  end
end
