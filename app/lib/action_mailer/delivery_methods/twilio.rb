# frozen_string_literal: true

# disable :reek:MissingSafeMethod
class ActionMailer::DeliveryMethods::Twilio
  def initialize(settings = {})
    self.settings = settings
  end

  # :reek:FeatureEnvy
  def deliver!(mail)
    message = mail.body.raw_source.strip
    client.messages.create(from: mail.from.first, to: mail.to.first, body: message)
  end

  # disable :reek:Attribute to follow ActionMailer convention
  attr_accessor :settings

  private

  def client
    @client ||= TwilioClientFactory.new_client
  end
end
