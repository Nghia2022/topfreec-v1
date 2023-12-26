# frozen_string_literal: true

class WorkHistory < ApplicationRecord
  include SalesforceHelpers

  self.table_name = 'salesforce.work_history__c'
  self.sobject_name = 'Work_history__c'

  belongs_to :contact, foreign_key: :person__c, primary_key: :sfid

  enumerize :status__c, in: { employed: '現職中', unemployed: '退職', in_planning: '退職予定' }

  def owner?(user)
    user.contact_sfid == person__c
  end

  scope :order_joined, -> { order(start_date__c: :desc) }
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
