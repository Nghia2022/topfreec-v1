# frozen_string_literal: true

module NotificationReceivable
  extend ActiveSupport::Concern

  included do
    helper_method :receipts
  end

  def receipts
    @receipts ||= if user_signed_in?
                    current_user.receipts.includes(:notification).order(created_at: :desc).page.per(5)
                  else
                    Receipt.none
                  end
  end
end
