# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Client::ResetPassword::ClientUser, type: :model do
  describe '.find_first_by_auth_conditions' do
    let(:attributes) do
      {
        email: contact.web_loginemail__c
      }
    end

    context 'when contact exists and client_user not exists' do
      let!(:contact) { FactoryBot.create(:contact, :client) }
      let(:confirmed_at) { Time.zone.parse('2020-10-01 00:00:00') }

      around do |ex|
        travel_to(confirmed_at) { ex.run }
      end

      it do
        expect do
          Client::ResetPassword::ClientUser.find_first_by_auth_conditions(attributes)
        end.to change(Client::ResetPassword::ClientUser, :count).by(1)
      end

      it do
        expect(Client::ResetPassword::ClientUser.find_first_by_auth_conditions(attributes)).to have_attributes(
          email:        contact.web_loginemail__c,
          contact_sfid: contact.sfid,
          confirmed_at:
        )
      end
    end

    context 'when contact and client_user exists' do
      let!(:contact) { FactoryBot.create(:contact, :client) }
      let!(:client_user) { FactoryBot.create(:client_user, email: contact.web_loginemail__c, contact:) }

      it do
        expect do
          Client::ResetPassword::ClientUser.find_first_by_auth_conditions(attributes)
        end.to not_change(Client::ResetPassword::ClientUser, :count)
      end
    end
  end
end
