# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Fc::Settings::ContactAttributable, type: :model do
  let(:contact) { FactoryBot.create(:contact, :fc) }
  let(:dummy_class) do
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes
      extend Fc::Settings::ContactAttributable

      attribute :experienced_works_main, array: :string
      alias_attribute :experienced_works_main__c, :experienced_works_main
    end
  end

  describe '.new_from_contact' do
    let(:form) { dummy_class.new_from_contact(contact) }
    subject { form.attribute_names }

    it { is_expected.to include 'experienced_works_main' }
    it { is_expected.to_not include 'email' }
  end
end
