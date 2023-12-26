# frozen_string_literal: true

module TaskExampleGroup
  def self.included(base)
    base.before(:each) do
      Rake.application.tasks.each(&:reenable)
    end
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    Rails.application.load_tasks
  end

  config.include TaskExampleGroup, type: :task
end
