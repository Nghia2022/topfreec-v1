# frozen_string_literal: true

module Messageable
  extend ActiveSupport::Concern

  included do
    has_many :receipts, class_name: 'Receipt', dependent: :destroy, as: :receiver
  end

  def notifications
    Notification.recipient(self).order(created_at: :desc)
  end
end
