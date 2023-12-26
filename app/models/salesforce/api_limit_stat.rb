# frozen_string_literal: true

class Salesforce::ApiLimitStat < ApplicationRecord
  before_save :set_daily_api_requests_calls

  private

  def set_daily_api_requests_calls
    self.daily_api_requests_calls = daily_api_requests_max - daily_api_requests_remaining
  end
end

# == Schema Information
#
# Table name: salesforce_api_limit_stats
#
#  id                           :bigint           not null, primary key
#  daily_api_requests_calls     :integer
#  daily_api_requests_max       :integer
#  daily_api_requests_remaining :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#
