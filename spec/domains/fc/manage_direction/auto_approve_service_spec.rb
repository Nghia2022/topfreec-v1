# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Fc::ManageDirection::AutoApproveService, type: :service do
  describe '.call' do
    subject { Fc::ManageDirection::AutoApproveService.call }
    let!(:direction_expired) do
      FactoryBot.create(:direction, :with_project, :waiting_for_fc, autoapprschedule_fc__c: Date.current)
    end
    let!(:direction_not_expired) do
      FactoryBot.create(:direction, :with_project, :waiting_for_fc, autoapprschedule_fc__c: Date.current + 1.day)
    end
    let!(:direction_for_cl) do
      FactoryBot.create(:direction, :with_project, :waiting_for_client, autoapprschedule_cl__c: Date.current)
    end
    let(:sf_contact) { FactoryBot.build_stubbed(:sf_contact) }

    before do
      stub_salesforce_create_request('Task', anything)
      allow_any_instance_of(Project).to receive_message_chain(:main_fc_contact, :to_sobject).and_return(sf_contact)
    end

    it do
      expect do
        subject
        direction_expired.reload
      end.to change { direction_expired.status__c }.from('waiting_for_fc').to('completed')
    end

    it do
      expect do
        subject
        direction_not_expired.reload
      end.to_not change { direction_not_expired.status__c }.from('waiting_for_fc')
    end

    it do
      expect do
        subject
        direction_not_expired.reload
      end.to_not change { direction_for_cl.status__c }.from('waiting_for_client')
    end
  end
end
