# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Salesforce::Picklists::ReloadJob, type: :job do
  subject(:job) { described_class.new }

  describe '#perform' do
    context 'when given no argument' do
      subject { job.perform }

      it do
        expect(Salesforce::Picklists::ReloadService).to receive(:call).with(sobject_name: nil)
        subject
      end
    end

    context 'when given sobject_name' do
      subject { job.perform(**args) }
      let(:args) { { sobject_name: 'Contact' } }

      it do
        expect(Salesforce::Picklists::ReloadService).to receive(:call).with(sobject_name: 'Contact')
        subject
      end
    end
  end
end
