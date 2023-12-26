# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Salesforce::Account, type: :model do
  describe '.null' do
    it do
      expect(Salesforce::Account.null.class).to eq(Salesforce::Account::NullObject)
    end
  end

  describe '.find' do
    subject { Salesforce::Account.find(sfid) }
    let(:sfid) { FactoryBot.generate(:sfid) }
    let(:sf_account) { FactoryBot.build(:sf_account_fc) }

    before do
      allow(Salesforce::Account.restforce).to receive(:select).with('Account', sfid, []).and_return(sf_account)
    end

    it do
      is_expected.to be_a(Salesforce::Account)
    end
  end
end
