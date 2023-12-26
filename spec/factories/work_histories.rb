# frozen_string_literal: true

FactoryBot.define do
  factory :work_history do
    sfid
    company_name__c { Faker::Company.name }
    status__c { WorkHistory.status__c.values.sample }
    start_date__c { Faker::Date.in_date_period(year: 2007).beginning_of_month }
    end_date__c { Faker::Date.in_date_period(year: 2020).end_of_month }
    position__c { Faker::Job.position }
    contact { FactoryBot.build(:contact) }
  end
end

# == Schema Information
#
# Table name: salesforce.work_history__c
#
#  id              :integer          not null, primary key
#  _hc_err         :text
#  _hc_lastop      :string(32)
#  company_name__c :string(255)
#  createddate     :datetime
#  end_date__c     :date
#  isdeleted       :boolean
#  name            :string(80)
#  person__c       :string(18)
#  position__c     :string(255)
#  sfid            :string(18)
#  start_date__c   :date
#  status__c       :string(255)
#  systemmodstamp  :datetime
#
# Indexes
#
#  hc_idx_work_history__c_start_date__c   (start_date__c)
#  hc_idx_work_history__c_systemmodstamp  (systemmodstamp)
#  hcu_idx_work_history__c_sfid           (sfid) UNIQUE
#
