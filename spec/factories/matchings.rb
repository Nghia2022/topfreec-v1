# frozen_string_literal: true

FactoryBot.define do
  factory :matching do
    sequence(:name) { |n| format('M-%<seq>06d', seq: n) }
    matching_status__c { :candidate }
    isactivewebentry__c { true }
    recordtypeid { :matching }
    createddate { Time.current }
    sfid

    transient do
      project_trait { [] }
      account_trait { [] }
    end

    trait :with_project do
      project { FactoryBot.build(:project, *project_trait) }
    end

    trait :with_account do
      account { FactoryBot.build(:account, *account_trait) }
    end

    trait :with_ng_reason do
      ng_reoson_text__c { 'ng reason' }
    end

    trait :no_ng_reason do
      ng_reoson_text__c { '' }
    end

    trait :with_resume_date do
      datelog_resumeapply__c { Time.current }
    end

    trait :no_resume_date do
      # NOOP
    end

    trait :candidate do
      matching_status__c { :candidate }
    end

    trait :resume_submitted do
      matching_status__c { :resume_submitted }
    end

    trait :with_status_of_stop_email do
      isstopstatuschangemail__c { true }
    end
  end
end

# == Schema Information
#
# Table name: salesforce.matching__c
#
#  id                                   :integer          not null, primary key
#  _hc_err                              :text
#  _hc_lastop                           :string(32)
#  client_mtg_date__c                   :date
#  createdbyid                          :string(18)
#  createddate                          :datetime
#  datelog_clfcmtg__c                   :date
#  datelog_entryoffer__c                :date
#  datelog_resumeapply__c               :date
#  fc__c                                :string(18)
#  isactivewebentry__c                  :boolean
#  isdeleted                            :boolean
#  isstopstatuschangemail__c            :boolean
#  komento__c                           :string(255)
#  matching_status__c                   :string(255)
#  matchingkeyid__c                     :string(15)
#  name                                 :string(80)
#  ng_reoson_text__c                    :string(255)
#  opportunity__c                       :string(18)
#  recordtypeid                         :string(18)
#  referfromentrydate__c                :date
#  referfrommatching__c                 :string(18)
#  referfrommatchingstatus__c           :string(128)
#  referfrommodifier__c                 :string(18)
#  referfromrejumesentdate__c           :date
#  referfromroot__c                     :string(128)
#  refertomatching__c                   :string(18)
#  refertomatching__r__matchingkeyid__c :string(15)
#  root__c                              :string(255)
#  sfid                                 :string(18)
#  systemmodstamp                       :datetime
#
# Indexes
#
#  hc_idx_matching__c_fc__c                (fc__c)
#  hc_idx_matching__c_isactivewebentry__c  (isactivewebentry__c)
#  hc_idx_matching__c_opportunity__c       (opportunity__c)
#  hc_idx_matching__c_recordtypeid         (recordtypeid)
#  hc_idx_matching__c_refertomatching__c   (refertomatching__c)
#  hc_idx_matching__c_systemmodstamp       (systemmodstamp)
#  hcu_idx_matching__c_matchingkeyid__c    (matchingkeyid__c) UNIQUE
#  hcu_idx_matching__c_sfid                (sfid) UNIQUE
#
