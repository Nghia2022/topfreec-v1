# frozen_string_literal: true

module Tasks
  class CreateService
    include Service
    include SalesforceHelpers

    def initialize(task:, **options)
      @task = task
      @options = options
    end

    attr_reader :task

    def call
      sf_task = Salesforce::Task.new(task.attributes)
      restforce.create!('Task', sf_task.as_json)
    end
  end
end
