# frozen_string_literal: true

class MatchingBase < ApplicationRecord
  include SalesforceHelpers
  include SalesforceTimestamp

  self.table_name = 'salesforce.matching__c'
  self.sobject_name = 'Matching__c'
  acts_as_recordtypable

  enumerize :recordtypeid, in: { matching: '01228000000gxWjAAI', master: '012000000000000AAA' }

  trigger.after(:insert) do
    <<-SQL.squish
      IF NEW.recordtypeid = '01228000000gxWjAAI' THEN
        INSERT INTO matching_events(matching_id, old_hc_lastop, new_hc_lastop, root, old_status, new_status, created_at, updated_at) VALUES(NEW.id, NULL, NEW._hc_lastop, NEW.root__c, NULL, NEW.matching_status__c, NOW(), NOW());
      END IF
    SQL
  end

  trigger.after(:update).of(:matching_status__c) do
    <<-SQL.squish
      IF NEW.recordtypeid = '01228000000gxWjAAI' THEN
        INSERT INTO matching_events(matching_id, old_hc_lastop, new_hc_lastop, root, old_status, new_status, created_at, updated_at) VALUES(NEW.id, OLD._hc_lastop, NEW._hc_lastop, NEW.root__c, OLD.matching_status__c, NEW.matching_status__c, NOW(), NOW());
      END IF
    SQL
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
