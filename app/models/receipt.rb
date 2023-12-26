# frozen_string_literal: true

class Receipt < ApplicationRecord
  belongs_to :notification
  belongs_to :receiver, polymorphic: true

  enumerize :mailbox, in: %i[inbox sentbox]

  scope :sentbox, -> { where(mailbox: :sentbox) }
  scope :inbox, -> { where(mailbox: :inbox) }
  scope :is_read, -> { where.not(read_at: nil) }
  scope :is_unread, -> { where(read_at: nil) }

  delegate :subject, to: :notification

  def is_read? # rubocop:disable Naming/PredicateName
    read_at?
  end

  def is_unread? # rubocop:disable Naming/PredicateName
    !is_read?
  end

  def mark_as_read(timestamp = Time.current)
    update(read_at: timestamp)
  end

  def mark_as_unread
    update(read_at: nil)
  end
end

# == Schema Information
#
# Table name: receipts
#
#  id              :bigint           not null, primary key
#  deleted_at      :datetime
#  mailbox         :string
#  read_at         :datetime
#  receiver_type   :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  notification_id :bigint
#  receiver_id     :bigint
#
# Indexes
#
#  index_receipts_on_mailbox                        (mailbox)
#  index_receipts_on_notification_id                (notification_id)
#  index_receipts_on_receiver_type_and_receiver_id  (receiver_type,receiver_id)
#
