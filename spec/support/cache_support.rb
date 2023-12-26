# frozen_string_literal: true

RSpec.configure do |config|
  config.around(:example, :cache) do |example|
    old_caching = ActionController::Base.perform_caching
    ActionController::Base.perform_caching = true

    example.run

    Rails.cache.clear
    ActionController::Base.perform_caching = old_caching
  end
end
