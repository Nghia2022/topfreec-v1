# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Fc::EditProfile::GeneralForm, type: :model do
  describe 'validations' do
    it do
      is_expected
        .to validate_presence_of(:phone)
        .and validate_numericality_of(:phone2).allow_nil
        .and validate_presence_of(:zipcode)
        .and validate_length_of(:last_name).is_at_most(60)
        .and validate_length_of(:first_name).is_at_most(60)
        .and validate_length_of(:last_name_kana).is_at_most(255)
        .and validate_length_of(:first_name_kana).is_at_most(255)
        .and validate_length_of(:zipcode).is_equal_to(7)
        .and validate_length_of(:phone).is_at_least(10).is_at_most(11)
        .and validate_length_of(:phone2).is_at_least(10).is_at_most(11)
        .and validate_length_of(:email).is_at_most(80)
        .and validate_length_of(:prefecture).is_at_most(80)
        .and validate_length_of(:city).is_at_most(40)
        .and validate_length_of(:building).is_at_most(255)
    end

    it_behaves_like 'validate_zipcode', :zipcode
    it_behaves_like 'validate_phone', :phone, :phone2
  end

  describe '.new_from_sobject' do
    let(:fc_user) { FactoryBot.build_stubbed(:sf_user) }
    let(:sf_contact) { FactoryBot.build_stubbed(:sf_contact) }

    it do
      new_form = Fc::EditProfile::GeneralForm.new_from_sobject_with_user(sf_contact, user: fc_user)
      expect(new_form).to have_attributes(
        LastName:    sf_contact.LastName,
        FirstName:   sf_contact.FirstName,
        Kana_Sei__c: sf_contact.Kana_Sei__c,
        Kana_Mei__c: sf_contact.Kana_Mei__c
      )
    end
  end

  describe '#save' do
    before do
      stub_salesforce_request
    end

    context 'when form is valid' do
      let(:fc_user) { FactoryBot.build_stubbed(:sf_user) }
      let(:contact) { FactoryBot.build_stubbed(:contact) }
      let(:sf_contact) { FactoryBot.build_stubbed(:sf_contact, Id: contact.sfid) }
      let(:form) { Fc::EditProfile::GeneralForm.new_from_sobject_with_user(sf_contact, user: fc_user) }

      it do
        expect do
          form.save(contact)
        end.to change(form, :persisted?).from(false).to(true)
      end
    end
  end
end
