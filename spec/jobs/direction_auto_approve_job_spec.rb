# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DirectionAutoApproveJob, type: :job do
  subject(:job) { described_class.new }

  describe '#perform' do
    subject { job.perform }

    let(:sf_contact) { FactoryBot.build_stubbed(:sf_contact) }

    before do
      allow_any_instance_of(Project).to receive_message_chain(:main_cl_contact, :to_sobject).and_return(sf_contact)
      allow_any_instance_of(Project).to receive_message_chain(:main_fc_contact, :to_sobject).and_return(sf_contact)
      stub_salesforce_create_request('Task', anything)
    end

    context "client's direction" do
      let!(:direction_expired) do
        FactoryBot.create(:direction, :with_project, :waiting_for_client, autoapprschedule_cl__c: Date.current)
      end

      it do
        expect do
          subject
        end.to change { Direction.waiting_for_client.count }.by(-1)
      end
    end

    context "fc's direction" do
      let!(:direction_expired) do
        FactoryBot.create(:direction, :with_project, :waiting_for_fc, autoapprschedule_fc__c: Date.current)
      end

      it do
        expect do
          subject
        end.to change { Direction.waiting_for_fc.count }.by(-1)
      end
    end

    context 'with client and fc' do
      let!(:direction_for_client) do
        FactoryBot.create(:direction, :with_project, :waiting_for_client, autoapprschedule_cl__c: Date.current)
      end
      let!(:direction_for_fc) do
        FactoryBot.create(:direction, :with_project, :waiting_for_fc, autoapprschedule_fc__c: Date.current)
      end

      it do
        expect do
          subject
          direction_for_client.reload
          direction_for_fc.reload
        end.to change(direction_for_client, :status__c).from('waiting_for_client').to('waiting_for_fc')
          .and change(direction_for_fc, :status__c).from('waiting_for_fc').to('completed')
      end
    end
  end
end
