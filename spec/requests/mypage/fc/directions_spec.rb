# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mypage::Fc::Directions', :erb, type: :request do
  subject(:perform) do
    send_request
    response
  end

  let!(:fc_user) { FactoryBot.create(:fc_user, :activated) }
  let(:account) { fc_user.account }
  let(:contact) { fc_user.contact }
  let(:sf_account_fc) { FactoryBot.build(:sf_account_fc) }
  let(:sf_contact) { FactoryBot.build(:sf_contact) }

  before do
    stub_salesforce_request
    allow_any_instance_of(Account).to receive(:to_sobject).and_return(sf_account_fc)
    allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
  end

  describe 'GET /mypage/fc/directions' do
    let(:direction_count) { 3 }
    let(:project) { FactoryBot.create(:project, :with_client, main_fc_contact: contact) }
    let!(:directions) do
      FactoryBot.create_list(:direction, direction_count, :waiting_for_fc, project:)
    end

    before do
      sign_in(fc_user)
    end

    it do
      is_expected.to have_http_status(:ok)
    end

    it do
      expect do
        send_request
      end.to change { Direction.where(firstcheckdatebyfc__c: nil).count }.from(direction_count).to(0)
    end

    it do
      expect(perform.body).to [
        have_selector(:testid, 'mypage/fc/directions/index'),
        have_selector('.workflow-dl', count: direction_count)
      ].inject(:and)
    end
  end
end
