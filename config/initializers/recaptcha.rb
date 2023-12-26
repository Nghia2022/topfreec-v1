# frozen_string_literal: true

Recaptcha.configure do |config|
  credentials = Rails.application.credentials.recaptcha
  config.site_key = credentials[:site_key]
  config.secret_key = credentials[:secret_key]
end
