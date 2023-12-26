# frozen_string_literal: true

module ClearBatchLoader
  def self.included(base)
    base.before(:each) { BatchLoader::Executor.clear_current }
  end
end

RSpec.configure do |config|
  config.include ClearBatchLoader
end
