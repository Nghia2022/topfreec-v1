# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountDecorator do
  subject { described_class.new(model) }

  describe '#client_name_name' do
    let(:model) { FactoryBot.build(:account, clientcompanyname__c: 'クライアント名') }

    it do
      expect(subject.client_name).to eq model.clientcompanyname__c
    end
  end
end
