# frozen_string_literal: true

FactoryBot.define do
  factory :experience do
    sfid
    member_amount__c { 1 }
    position__c { '役割' }
    details_self__c { '説明' }
    detail_mws__c { '' }
    start_date__c { '2019-04-01' }
    end_date__c { '2020-03-01' }

    transient do
      client_trait { [] }
      project_trait { [] }
    end

    trait :with_project do
      after(:build, :stub) do |experience, evaluator|
        experience.project = experience.project = FactoryBot.build(:project, *evaluator.project_trait)
      end
    end

    trait :published do
      openflag__c { true }
    end

    trait :closed do
      openflag__c { false }
    end
  end
end

# == Schema Information
#
# Table name: salesforce.experience__c
#
#  id               :integer          not null, primary key
#  _hc_err          :text
#  _hc_lastop       :string(32)
#  activeflag__c    :boolean
#  createddate      :datetime
#  detail_mws__c    :string(5000)
#  details_self__c  :string(5000)
#  end_date__c      :date
#  isdeleted        :boolean
#  member_amount__c :float
#  name             :string(80)
#  openflag__c      :boolean
#  opportunity__c   :string(18)
#  organization__c  :string(255)
#  position__c      :string(255)
#  recordtypeid     :string(18)
#  sfid             :string(18)
#  start_date__c    :date
#  systemmodstamp   :datetime
#  who__c           :string(18)
#
# Indexes
#
#  hc_idx_experience__c_systemmodstamp  (systemmodstamp)
#  hcu_idx_experience__c_sfid           (sfid) UNIQUE
#
