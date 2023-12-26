# frozen_string_literal: true

class DirectionEvent < ApplicationRecord
  belongs_to :direction

  enumerize :old_status, in: Direction::STATUSES
  enumerize :new_status, in: Direction::STATUSES

  def perform_request_confirmation_to_client?
    [
      mail_queued?,
      direction&.may_request_confirmation_to_client?
    ].all?
  end

  def perform_request_reconfirmation_to_client?
    [
      changed_in_salesforce?,
      mail_queued?,
      direction&.may_request_reconfirmation_to_client?
    ].all?
  end

  def perform_finalize?
    changed_in_salesforce? && old_status.waiting_for_fc? && new_status.completed?
  end

  def status_changed?
    old_status != new_status
  end

  def changed_in_salesforce?
    old_hc_lastop == 'SYNCED' && new_hc_lastop == 'SYNCED'
  end
end

# == Schema Information
#
# Table name: direction_events
#
#  id             :bigint           not null, primary key
#  direction_sfid :string
#  mail_queued    :boolean          default(FALSE)
#  new_hc_lastop  :string
#  new_status     :string
#  old_hc_lastop  :string
#  old_status     :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  direction_id   :integer
#
# Indexes
#
#  index_direction_events_on_direction_id    (direction_id)
#  index_direction_events_on_direction_sfid  (direction_sfid)
#
