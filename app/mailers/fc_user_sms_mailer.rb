# frozen_string_literal: true

class FcUserSmsMailer < ApplicationMailer
  self.delivery_method = :sms

  def two_factor(user, code)
    mail from:, to: user.phone_normalized, body: "認証コード: #{code}"
  end

  private

  def from
    Rails.application.credentials.dig(:twilio, :phone_number)
  end
end
