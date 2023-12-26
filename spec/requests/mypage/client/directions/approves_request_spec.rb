# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mypage::Client::Directions::Approves', type: :request do
  subject do
    send_request
    response
  end

  let!(:client_user) { FactoryBot.create(:client_user, :with_contact) }
  let(:contact) { client_user.contact }
  let(:direction_id) { direction.id }

  describe 'GET /mypage/cl/directions/:direction_id/approve' do
    let(:project) { FactoryBot.create(:project, main_cl_contact: contact) }
    let!(:direction) { FactoryBot.create(:direction, :waiting_for_client, project:) }

    before do
      sign_in(client_user)
    end

    it do
      is_expected.to have_http_status(:ok)
    end
  end

  describe 'POST /mypage/cl/directions/:direction_id/approve' do
    let(:project) { FactoryBot.create(:project, main_cl_contact: contact) }
    let!(:direction) { FactoryBot.create(:direction, :waiting_for_client, project:) }
    let(:sf_contact) { FactoryBot.build(:sf_contact) }

    before do
      stub_salesforce_create_request('Task', anything)
      allow(client_user.contact).to receive(:to_sobject).and_return(sf_contact)
      sign_in(client_user)
    end

    it do
      is_expected.to redirect_to(mypage_client_directions_path)
    end

    it do
      expect do
        send_request
      end.to change { direction.reload.status__c }.from('waiting_for_client').to('waiting_for_fc')
    end
  end
end
