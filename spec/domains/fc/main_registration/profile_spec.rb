# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Fc::MainRegistration::Profile, type: :model do
  let(:sf_contact) { FactoryBot.build_stubbed(:sf_contact, :fc) }
  let(:contact) { FactoryBot.build_stubbed(:contact, :fc) }

  describe '.new_from_sobject' do
    subject { described_class.new_from_sobject(contact.to_sobject) }

    before do
      stub_salesforce_request
      allow_any_instance_of(Restforce::Concerns::API).to receive(:select).and_return(sf_contact)
    end

    it do
      is_expected.to have_attributes(
        MailingState:      sf_contact.MailingState,
        MailingCity:       sf_contact.MailingCity,
        MailingStreet:     sf_contact.MailingStreet,
        MailingPostalCode: sf_contact.MailingPostalCode
      )
    end
  end

  describe '#aliase_attributes' do
    let(:profile) { described_class.new_from_sobject(contact.to_sobject) }

    subject { profile.aliase_attributes }

    before do
      stub_salesforce_request
      allow_any_instance_of(Restforce::Concerns::API).to receive(:select).and_return(sf_contact)
    end

    it do
      is_expected.to eq(
        'prefecture' => sf_contact.MailingState,
        'city' => sf_contact.MailingCity,
        'building' => sf_contact.MailingStreet,
        'zipcode' => sf_contact.MailingPostalCode
      )
    end
  end
end
