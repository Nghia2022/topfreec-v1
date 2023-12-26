# frozen_string_literal: true

ActiveSupport::Reloader.to_prepare do
  ActionMailer::Base.add_delivery_method :sms, ActionMailer::DeliveryMethods::Twilio
end

unless Rails.env.production?
  ActiveSupport::Reloader.to_prepare do
    Mail.register_interceptor DemuxInterceptor.new
  end
end
