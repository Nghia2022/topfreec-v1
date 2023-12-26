# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider OmniAuth::Strategies::SalesforceSandbox,
           Rails.application.credentials.dig(:salesforce, :client_id),
           Rails.application.credentials.dig(:salesforce, :client_secret),
           name: 'salesforce'
end

OmniAuth.config.on_failure = proc { |env| OmniAuth::FailureEndpoint.new(env).redirect_to_failure }
