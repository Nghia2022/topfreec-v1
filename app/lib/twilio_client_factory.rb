# frozen_string_literal: true

module TwilioClientFactory
  def self.new_client
    Twilio::REST::Client.new
  end
end
