# frozen_string_literal: true

module Fc::ManageDirection
  class Direction < ActiveType::Record[Direction]
    alias_attribute :direction_month, :directionmonth__c
    alias_attribute :direction_detail, :directiondetail__c
    alias_attribute :comment_from_fc, :commentfromfc__c
    alias_attribute :status, :status__c
    alias_attribute :auto_approve_schedule_fc, :autoapprschedule_fc__c
    alias_attribute :approved_date_by_cl, :approveddatebycl__c
    alias_attribute :approved_date_by_fc, :approveddatebyfc__c
    alias_attribute :approver_of_fc, :approveroffc__c

    validates :comment_from_fc, presence: true, if: -> { status.rejected? }

    class << self
      def open_unread
        where(firstcheckdatebyfc__c: nil).touch_all(:firstcheckdatebyfc__c) # rubocop:disable Rails/SkipsModelValidations
      end
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
