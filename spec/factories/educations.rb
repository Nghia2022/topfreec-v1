# frozen_string_literal: true

FactoryBot.define do
  factory :education do
    sfid
    school_name { Faker::University.name }
    department  { Faker::Educator.subject }
    joined { '2003-04' }
    left { '2007-03' }

    after(:stub) do |record|
      record.Id = record.sfid
    end

    transient do
      account_trait { [] }
    end

    trait :with_account do
      account { FactoryBot.build(:account, *account_trait) }
    end
  end
end

# == Schema Information
#
# Table name: educations
#
#  contact_sfid :string
#  degree       :string
#  degree_name  :string
#  department   :string
#  joined       :string
#  left         :string
#  major        :string
#  school_name  :string
#  school_type  :string
#  sfid         :string           not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_educations_on_contact_sfid  (contact_sfid)
#
