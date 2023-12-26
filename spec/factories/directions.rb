# frozen_string_literal: true

FactoryBot.define do
  factory :direction do
    status__c { :in_prepare }

    transient do
      project_trait { [] }
    end

    trait :with_project do
      project { FactoryBot.build(:project, *project_trait) }
    end

    trait :approved_by_fc do
      status__c { :completed }
      approveddatebyfc__c { Time.current }
      isapprovedbyfc__c { true }
    end

    trait :in_prepare do
      status__c { :in_prepare }
    end

    trait :rejected_by_client do
      status__c { :rejected }
      newdirectiondetail__c { 'detail' }
    end

    trait :rejected_by_fc do
      status__c { :rejected }
      commentfromfc__c { 'comment' }
    end

    trait :waiting_for_client do
      status__c { :waiting_for_client }
      isapprovedbycl__c { false }
    end

    trait :waiting_for_fc do
      status__c { :waiting_for_fc }
      isapprovedbycl__c { true }
    end

    trait :completed do
      status__c { :completed }
    end
  end
end

# == Schema Information
#
# Table name: salesforce.direction__c
#
#  id                         :integer          not null, primary key
#  _hc_err                    :text
#  _hc_lastop                 :string(32)
#  approveddatebycl__c        :datetime
#  approveddatebyfc__c        :datetime
#  approverofcl__c            :string(255)
#  approveroffc__c            :string(255)
#  autoapprinterval_cl__c     :float
#  autoapprinterval_fc__c     :float
#  autoapproveddatetime_cl__c :datetime
#  autoapproveddatetime_fc__c :datetime
#  autoapprschedule_cl__c     :date
#  autoapprschedule_fc__c     :date
#  changedhistories__c        :text
#  commentfromfc__c           :text
#  createddate                :datetime
#  directiondetail__c         :text
#  directionmonth__c          :string(255)
#  directionmonthdate__c      :date
#  fc__c                      :string(18)
#  firstcheckdatebycl__c      :datetime
#  firstcheckdatebyfc__c      :datetime
#  isapprovedbycl__c          :boolean
#  isapprovedbyfc__c          :boolean
#  isdeleted                  :boolean
#  ismailqueue__c             :boolean
#  name                       :string(80)
#  newdirectiondetail__c      :text
#  opportunity__c             :string(18)
#  requestdatetime__c         :datetime
#  sfid                       :string(18)
#  status__c                  :string(255)
#  systemmodstamp             :datetime
#
# Indexes
#
#  hc_idx_direction__c_systemmodstamp  (systemmodstamp)
#  hcu_idx_direction__c_sfid           (sfid) UNIQUE
#
