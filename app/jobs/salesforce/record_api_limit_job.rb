# frozen_string_literal: true

class Salesforce::RecordApiLimitJob < ApplicationJob
  queue_as :default

  def perform
    max = limits.dig(:DailyApiRequests, :Max)
    remaining = limits.dig(:DailyApiRequests, :Remaining)

    Salesforce::ApiLimitStat.create!(daily_api_requests_max: max, daily_api_requests_remaining: remaining)
  end

  private

  def restforce
    @restforce ||= RestforceFactory.new_client
  end

  def limits
    @limits ||= restforce.limits
  end
end
