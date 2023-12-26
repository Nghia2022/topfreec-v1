# frozen_string_literal: true

unless Rails.env.test?
  redis_url = ENV.fetch('REDIS_URL', nil)
  redis_params = {
    url: "#{redis_url}/0"
  }
  redis_params.merge!(ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }) if redis_url.start_with? 'rediss'

  Rails.application.config.session_store :redis_session_store,
                                         serializer: :json,
                                         redis:      redis_params
end
