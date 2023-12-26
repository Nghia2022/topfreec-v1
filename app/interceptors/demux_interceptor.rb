# frozen_string_literal: true

class DemuxInterceptor
  def delivering_email(message)
    return if mailtrap?(message)

    demux(message)
    filter_recipients(message)

    message.perform_deliveries = false if message.to.empty?
  end

  private

  def filter_invalid(email)
    email.match?(/\.invalid\Z/)
  end

  def demux(message)
    mail = message.dup
    ActionMailer::Base.wrap_delivery_behavior(mail, :mailtrap)
    mail.deliver!
  end

  # :reek:DuplicateMethodCall, :reek:FeatureEnvy
  def filter_recipients(message)
    filter = method(:filter_invalid)
    message.to = message.to.to_a.reject(&filter)
    message.cc = message.cc.to_a.reject(&filter)
  end

  def mailtrap?(message)
    message.delivery_method.settings[:kind] == :mailtrap
  end
end
