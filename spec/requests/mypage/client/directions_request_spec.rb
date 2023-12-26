# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mypage::Client::Directions', type: :request do
  subject(:perform) do
    send_request
    response
  end

  let!(:client_user) { FactoryBot.create(:client_user, contact:) }
  let(:account) { FactoryBot.create(:account_client) }
  let(:contact) { FactoryBot.create(:contact, :client, account:) }
  let(:sf_account_client) { FactoryBot.build(:sf_account_client) }
  let(:sf_contact) { FactoryBot.build(:sf_contact) }

  before do
    stub_salesforce_request
    allow_any_instance_of(Account).to receive(:to_sobject).and_return(sf_account_client)
    allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
  end

  describe 'GET /mypage/cl/directions' do
    let(:direction_count) { 3 }
    let(:project) { FactoryBot.create(:project, client: account, main_cl_contact: contact) }
    let!(:directions) do
      FactoryBot.create_list(:direction, direction_count, :waiting_for_client, project:)
    end

    before do
      sign_in(client_user)
    end

    it do
      is_expected.to have_http_status(:ok)
    end

    shared_examples 'appears target directions' do
      it do
        expect do
          send_request
        end.to change { Direction.where(firstcheckdatebycl__c: nil).count }.from(direction_count).to(0)
      end

      it do
        expect(perform.body).to [
          have_selector(:testid, 'mypage/client/directions/index'),
          have_selector('.workflow-dl', count: direction_count)
        ].inject(:and)
      end
    end

    context 'when main cl contact' do
      let(:project) { FactoryBot.create(:project, client: account, main_cl_contact: contact) }

      include_examples 'appears target directions'
    end

    context 'when sub cl contact' do
      let(:project) { FactoryBot.create(:project, client: account, sub_cl_contact: contact) }

      include_examples 'appears target directions'
    end
  end
end
