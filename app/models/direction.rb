# frozen_string_literal: true

class Direction < ApplicationRecord
  include SalesforceHelpers
  include SalesforceTimestamp
  include AASM

  include Directions::Workflow

  self.table_name = 'salesforce.direction__c'
  self.sobject_name = 'Direction__c'

  trigger.after(:insert) do
    <<-SQL.squish
      INSERT INTO direction_events(direction_id, direction_sfid, old_hc_lastop, new_hc_lastop, old_status, new_status, created_at, updated_at, mail_queued) VALUES(NEW.id, NEW.sfid, NULL, NEW._hc_lastop, NULL, NEW.status__c, NOW(), NOW(), NEW.ismailqueue__c)
    SQL
  end

  trigger.after(:update).of(:status__c, :ismailqueue__c) do
    <<-SQL.squish
      IF OLD._hc_lastop = 'SYNCED' AND NEW._hc_lastop = 'SYNCED' THEN
        INSERT INTO direction_events(direction_id, direction_sfid, old_hc_lastop, new_hc_lastop, old_status, new_status, created_at, updated_at, mail_queued) VALUES(NEW.id, NEW.sfid, OLD._hc_lastop, NEW._hc_lastop, OLD.status__c, NEW.status__c, NOW(), NOW(), NEW.ismailqueue__c);
      END IF
    SQL
  end

  attribute :autoapprinterval_cl__c, :integer
  attribute :autoapprinterval_fc__c, :integer

  belongs_to :project, foreign_key: :opportunity__c, primary_key: :sfid

  scope :filter_by_status, ->(status) { status.presence && status != 'all' ? where(status__c: status) : all }
  scope :latest_order, -> { order(directionmonthdate__c: :desc) }

  delegate :name, to: :project, prefix: true, allow_nil: true

  STATUSES = {
    in_prepare:         '準備中',
    rejected:           '差戻し',
    waiting_for_client: 'クライアント確認中',
    waiting_for_fc:     'FC確認中',
    completed:          '完了'
  }.freeze

  enumerize :status__c, in: STATUSES, default: :in_prepare, scope: true

  aasm column: :status__c, enum: true do
    Direction.status__c.each_value do |value|
      state value.to_sym, initial: value == Direction.status__c.default_value
    end

    event :request_confirmation_to_client do
      after_commit :after_commit_request_confirmation_to_client

      transitions(from:    :in_prepare,
                  to:      :waiting_for_client,
                  after:   :after_request_confirmation_to_client,
                  success: :publish_request_confirmation_to_client_task)
    end

    event :request_reconfirmation_to_client do
      after_commit :after_commit_request_reconfirmation_to_client

      transitions(from:    :rejected,
                  to:      :waiting_for_client,
                  after:   :after_request_reconfirmation_to_client,
                  success: :publish_request_confirmation_to_client_task)
    end

    event :approve_by_client do
      after_commit :after_commit_approve_by_client

      transitions(from:    :waiting_for_client,
                  to:      :waiting_for_fc,
                  after:   :after_approved_by_client,
                  success: :publish_approved_by_client_task,
                  guard:   :can_manage_by_client?)
    end

    event :auto_approve_by_client do
      after_commit :after_commit_auto_approve_by_client

      transitions(from:    :waiting_for_client,
                  to:      :waiting_for_fc,
                  after:   :after_auto_approved_by_client,
                  success: :publish_auto_approved_by_client_task)
    end

    event :reject_by_client do
      after_commit :after_commit_reject_by_client

      transitions(from:    :waiting_for_client,
                  to:      :rejected,
                  after:   :after_rejected_by_client,
                  success: :publish_rejected_by_client_task,
                  guard:   :can_manage_by_client?)
    end

    event :approve_by_fc do
      after_commit :after_commit_approve_by_fc

      transitions(from:    :waiting_for_fc,
                  to:      :completed,
                  after:   :after_approved_by_fc,
                  success: :publish_approved_by_fc_task,
                  guard:   :can_manage_by_fc?)
    end

    event :auto_approve_by_fc do
      after_commit :after_commit_auto_approve_by_fc

      transitions(from:    :waiting_for_fc,
                  to:      :completed,
                  after:   :after_auto_approved_by_fc,
                  success: :publish_auto_approved_by_fc_task)
    end

    event :reject_by_fc do
      after_commit :after_commit_reject_by_fc

      transitions(from:    :waiting_for_fc,
                  to:      :rejected,
                  after:   :after_rejected_by_fc,
                  guard:   :can_manage_by_fc?,
                  success: :publish_rejected_by_fc_task)
    end

    event :finalize_by_mws do
      transitions(from:  :completed,
                  to:    :completed,
                  after: :after_finalize_by_mws)
    end
  end

  def can_manage_by_fc?(fc_user:, **_options)
    status__c.waiting_for_fc? && !isapprovedbyfc__c? && project.manager?(fc_user)
  end

  def can_manage_by_client?(client_user:, **_options)
    status__c.waiting_for_client? && !isapprovedbycl__c? && project.owner?(client_user)
  end

  rails_admin do
    list do
      include_fields :_hc_err, :_hc_lastop, :name, :status__c, :project, :systemmodstamp
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
