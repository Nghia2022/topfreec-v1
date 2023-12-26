# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AggregatePageViewsJob, type: :job do
  subject(:job) { described_class.new }

  describe '#perform' do
    subject { job.perform(args) }

    context 'when given a argument daily' do
      let(:args) { 'daily' }

      it do
        expect(ProjectDailyPageView).to receive(:refresh)
        subject
      end
    end

    context 'when given a argument weekly' do
      let(:args) { 'weekly' }

      it do
        expect(ProjectWeeklyPageView).to receive(:refresh)
        subject
      end
    end

    context 'when given a argument monthly' do
      let(:args) { 'monthly' }

      it do
        expect(ProjectMonthlyPageView).to receive(:refresh)
        subject
      end
    end
  end
end
