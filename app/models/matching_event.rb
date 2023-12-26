# frozen_string_literal: true

class MatchingEvent < ApplicationRecord
  belongs_to :matching

  enumerize :root, in: Matching::ROOTS
  enumerize :old_status, in: Matching::STATUSES
  enumerize :new_status, in: Matching::STATUSES

  class << self
    def notify_matching(method)
      define_method method do |*options|
        MatchingMailer.public_send(method, *options).deliver_later
      end
    end
  end

  notify_matching :notify_candidate_to_fc
  notify_matching :notify_fc_declined_entry_to_fc
  notify_matching :notify_not_eligible_for_entry_to_fc
  notify_matching :notify_client_ng_after_resume_submitted_to_fc
  notify_matching :notify_fc_declining_to_fc
  notify_matching :notify_fc_declined_after_mtg_to_fc
  notify_matching :notify_lost_candidate_to_fc
  notify_matching :notify_lost_entry_target_to_fc
  notify_matching :notify_lost_entry_completed_to_fc
  notify_matching :notify_lost_resume_submitted_to_fc

  def notify_to_fc_user
    return unless notify_to_fc_user?

    public_send("notify_#{new_status}_to_fc", matching)
  end

  private

  # :reek:NilCheck
  def notify_to_fc_user?
    [
      status_changed?,
      notification_target_status?,
      notifiable_fc_user?,
      published_project?,
      !ignored_operation?,
      notifiable_matching?
    ].all?
  end

  def status_changed?
    old_status != new_status
  end

  def notification_target_status?
    notification_target_status_for_applied? || notification_target_status_for_recommended?
  end

  def notification_target_status_for_applied?
    Matching::APPLIED_FROM_FC_ROOTES.include?(root.to_sym) && %i[
      candidate
      fc_declined_entry
      not_eligible_for_entry
      client_ng_after_resume_submitted
      fc_declining
      fc_declined_after_mtg
      lost_candidate
      lost_entry_target
      lost_entry_completed
      lost_resume_submitted
    ].include?(new_status.to_sym)
  end

  def notification_target_status_for_recommended?
    Matching::APPLIED_FROM_FC_ROOTES.exclude?(root.to_sym) && %i[
      client_ng_after_resume_submitted
      fc_declining
      fc_declined_after_mtg
      lost_resume_submitted
    ].include?(new_status.to_sym)
  end

  def notifiable_fc_user?
    account&.fcweb_release__c? && contact.web_loginemail__c?
  end

  def account
    @account ||= matching.account
  end

  def contact
    @contact ||= account.person
  end

  def notifiable_matching?
    Matching::NOTIFABLE_WITH_STOP_STATUS_CHANGE_EMAIL.include?(new_status.to_sym) || !matching.isstopstatuschangemail__c?
  end

  def published_project?
    matching.project.web_publishdatetime__c?
  end

  def changed_in_salesforce?
    old_hc_lastop == 'SYNCED' && new_hc_lastop == 'SYNCED'
  end

  def ignored_operation?
    changed_in_salesforce? && %i[fc_declining fc_declined_entry].include?(new_status.to_sym)
  end
end

MatchingEvent.enumerized_attributes[:old_status].extend Enumerize::AllowInvalid
MatchingEvent.enumerized_attributes[:new_status].extend Enumerize::AllowInvalid

# == Schema Information
#
# Table name: matching_events
#
#  id            :bigint           not null, primary key
#  new_hc_lastop :string
#  new_status    :string
#  old_hc_lastop :string
#  old_status    :string
#  root          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  matching_id   :integer
#
# Indexes
#
#  index_matching_events_on_matching_id  (matching_id)
#
