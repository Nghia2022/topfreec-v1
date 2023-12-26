# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Client::DirectionsController, type: :controller do
  describe '#directions' do
    subject { controller.send(:directions).object }

    let(:client_user) { FactoryBot.create(:client_user, :with_contact) }
    let(:project_trait) { [main_cl_contact: client_user.contact] }

    named_let!(:directions) do
      [
        FactoryBot.create(:direction, :with_project, project_trait:, status__c: :waiting_for_client, directionmonthdate__c: '2020-10-03'),
        FactoryBot.create(:direction, :with_project, project_trait:, status__c: :waiting_for_client, directionmonthdate__c: '2020-10-01'),
        FactoryBot.create(:direction, :with_project, project_trait:, status__c: :waiting_for_client, directionmonthdate__c: '2020-10-02')
      ].map do |direction|
        ActiveType.cast(direction, Client::ManageDirection::Direction)
      end.sort_by(&:directionmonthdate__c).reverse
    end

    before do
      allow(controller).to receive(:current_client_user).and_return(client_user)
      allow(controller).to receive(:pundit_user).and_return(client_user)
    end

    it do
      is_expected.to eq directions
    end
  end
end
