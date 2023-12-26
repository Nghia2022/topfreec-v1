# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Salesforce::ApiLimitStat, type: :model do
  describe 'callbacks' do
    describe '#set_daily_api_requests_calls' do
      it do
        model = Salesforce::ApiLimitStat.new(daily_api_requests_max: 5_000_000, daily_api_requests_remaining: 4_999_000)
        expect do
          model.run_callbacks(:save)
        end.to change(model, :daily_api_requests_calls).from(nil).to(1000)
      end
    end
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
