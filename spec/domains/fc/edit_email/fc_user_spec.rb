# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Fc::EditEmail::FcUser, type: :model do
  describe 'validations' do
    subject { ActiveType.cast(model, described_class) }
    let(:model) { FactoryBot.build_stubbed(:fc_user, contact: my_contact) }
    let!(:my_contact) { FactoryBot.create(:contact, :client) }
    let!(:another_contact) { FactoryBot.create(:contact, :client) }

    it do
      is_expected.to validate_presence_of(:email)
    end

    it do
      is_expected.to_not allow_value('').for(:email)
    end

    it do
      is_expected.to_not allow_value(subject.email).for(:email)
    end

    it do
      is_expected.to allow_value(my_contact.web_loginemail__c).for(:email)
    end

    it do
      is_expected.to_not allow_value(another_contact.web_loginemail__c).for(:email)
    end
  end
end
