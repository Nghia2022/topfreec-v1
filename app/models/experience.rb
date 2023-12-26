# frozen_string_literal: true

class Experience < ApplicationRecord
  include SalesforceHelpers

  self.table_name = 'salesforce.experience__c'
  self.sobject_name = 'Experience__c'

  belongs_to :project, foreign_key: :opportunity__c, primary_key: :sfid, optional: true
  belongs_to :contact, foreign_key: :who__c, primary_key: :sfid, optional: true

  scope :oldest, -> { order(start_date__c: :asc) }

  def close
    update(openflag__c: false)
  end

  def publish
    update(openflag__c: true)
  end

  def project?
    project.present?
  end

  def owner?(user)
    user.contact.accountid == contact&.accountid
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
