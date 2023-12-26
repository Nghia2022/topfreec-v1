# frozen_string_literal: true

require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock

  VCR.turn_off!
end

RSpec.configure do |config|
  config.around(:each, :vcr) do |example|
    VCR.turn_on!
    example.run
    VCR.turn_off!
  end
end
