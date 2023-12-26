# frozen_string_literal: true

FactoryBot.define do
  factory :case_form, class: 'Cases::CaseForm' do
    email { Faker::Internet.email }
    last_name { faker_last_name.to_s }
    first_name { faker_first_name.to_s }
    last_name_kana { faker_last_name.yomi }
    first_name_kana { faker_first_name.yomi }
    name do
      "#{last_name} #{first_name} (#{last_name.yomi} #{first_name.yomi})"
    end
    phone { Faker::PhoneNumber.phone_number }
    description do
      3.times.map { Faker::Lorem.sentence }.join("\n")
    end
    case_type { Cases::CaseForm.case_type.values.sample }

    transient do
      faker_last_name { Faker::Japanese::Name.last_name }
      faker_first_name { Faker::Japanese::Name.first_name }
    end
  end
end
