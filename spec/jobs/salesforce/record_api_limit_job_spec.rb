# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Salesforce::RecordApiLimitJob, type: :job do
  subject(:job) { described_class.new }

  describe '#perform' do
    subject { job.perform }

    let(:limits_response) do
      Restforce::Mash.new(
        DailyApiRequests: {
          'Max' => 5_000_000,
          'Remaining' => 4_999_000
        }
      )
    end

    before do
      allow_any_instance_of(Restforce::Concerns::API).to receive(:limits).and_return(limits_response)
    end

    describe 'create a Salesforce::ApiLimitStat record' do
      it do
        expect do
          subject
        end.to change(Salesforce::ApiLimitStat, :count).by(1)
      end

      describe 'attributes' do
        it do
          is_expected.to have_attributes(
            daily_api_requests_max:       5_000_000,
            daily_api_requests_remaining: 4_999_000,
            daily_api_requests_calls:     1000
          )
        end
      end
    end
  end
end
