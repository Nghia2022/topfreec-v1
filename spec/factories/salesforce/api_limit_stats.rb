# frozen_string_literal: true

FactoryBot.define do
  factory :salesforce_api_limit_stat, class: 'Salesforce::ApiLimitStat' do
    daily_api_requests_max { 5_000_000 }
    daily_api_requests_calls { Random.rand 10_000 }
    daily_api_requests_remaining { daily_api_requests_max - daily_api_requests_calls }
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
