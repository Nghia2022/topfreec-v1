# frozen_string_literal: true

if ENV['REDIS_URL']
  redis_url = ENV['REDIS_URL']
  redis_params = {
    url: "#{redis_url}/1"
  }
  redis_params.merge!(ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }) if redis_url.start_with? 'rediss'

  Sidekiq.configure_client do |config|
    config.redis = redis_params
  end

  Sidekiq.configure_server do |config|
    config.redis = redis_params
  end
end
