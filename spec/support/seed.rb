# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:suite) do
    SeedFu.quiet = true
    SeedFu.seed
  end
end
