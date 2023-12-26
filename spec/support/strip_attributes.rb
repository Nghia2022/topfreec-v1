# frozen_string_literal: true

require 'strip_attributes/matchers'

RSpec.configure do |config|
  config.include StripAttributes::Matchers
end
