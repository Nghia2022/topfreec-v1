# frozen_string_literal: true

class Notification < ApplicationRecord
  extend Enumerize

  has_many :receipts, dependent: :destroy

  enumerize :kind, in: %i[matching_remaining direction_workflow]

  scope :recipient, lambda { |receipient|
    joins(:receipts).where(receipts: { receiver: receipient })
  }

  def notify(recipient, strategy = SimpleStrategy)
    strategy.call([recipient], self)
  end

  class << self
    def notify_all(recipients, notification, strategy = SimpleStrategy)
      strategy.call(recipients, notification)
    end
  end

  class NotificationStragegy
    def initialize(recipients, notification)
      @recipients = recipients
      @notification = notification
    end

    attr_reader :recipients, :notification

    def self.call(*)
      new(*).call
    end
  end

  class SimpleStrategy < NotificationStragegy
    def call
      recipients.map do |recipient|
        recipient.receipts.create!(notification:, mailbox: :inbox)
      end
    end
  end

  class InsertManagerStrategy < NotificationStragegy
    # :nocov:
    def call
      # TODO
      raise NotImplementedError
    end
    # :nocov:
  end
end

# == Schema Information
#
# Table name: notifications
#
#  id                   :bigint           not null, primary key
#  body                 :text
#  draft                :boolean          default(FALSE)
#  kind                 :string
#  link                 :string(1024)
#  notification_code    :string
#  notified_object_type :string
#  sender_type          :string
#  subject              :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  notified_object_id   :bigint
#  sender_id            :bigint
#
# Indexes
#
#  index_notifications_on_kind                       (kind)
#  index_notifications_on_sender_type_and_sender_id  (sender_type,sender_id)
#  notifications_notified_object                     (notified_object_type,notified_object_id)
#
