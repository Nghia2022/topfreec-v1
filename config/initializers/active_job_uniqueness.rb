# frozen_string_literal: true

ActiveJob::Uniqueness.configure do |config|
  # Global default expiration for lock keys. Each job can define its own ttl via :lock_ttl option.
  # Stategy :until_and_while_executing also accept :on_runtime_ttl option.
  #
  # config.lock_ttl = 1.day

  # Prefix for lock keys. Can not be set per job.
  #
  # config.lock_prefix = 'activejob_uniqueness'

  # Default action on lock conflict. Can be set per job.
  # Stategy :until_and_while_executing also accept :on_runtime_conflict option.
  # Allowed values are
  #   :raise - raises ActiveJob::Uniqueness::JobNotUnique
  #   :log - instruments ActiveSupport::Notifications and logs event to the ActiveJob::Logger
  #   proc - custom Proc. For example, ->(job) { job.logger.info('Oops') }
  #
  # config.on_conflict = :raise

  # Digest method for lock keys generating. Expected to have `hexdigest` class method.
  #
  # config.digest_method = OpenSSL::Digest::MD5

  # Array of redis servers for Redlock quorum.
  # Read more at https://github.com/leandromoreira/redlock-rb#redis-client-configuration
  #
  unless Rails.env.test?
    redis_url = ENV.fetch('REDIS_URL', nil)
    redis_params = { url: "#{redis_url}/1" }
    redis_params[:ssl_params] = { verify_mode: OpenSSL::SSL::VERIFY_NONE } if redis_url.start_with? 'rediss'

    config.redlock_servers = [redis_params]
  end

  # Custom options for Redlock.
  # Read more at https://github.com/leandromoreira/redlock-rb#redlock-configuration
  #
  # config.redlock_options = {}

  # Custom strategies.
  # config.lock_strategies = { my_strategy: MyStrategy }
  #
  # config.lock_strategies = {}
end
