# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExperienceDecorator do
  subject { described_class.new(model) }
  let(:model) { FactoryBot.build(:experience) }

  describe '#joined' do
    let(:model) { FactoryBot.build(:experience, start_date__c: '2020-01-01') }

    pending do
      expect(subject.joined).to eq '2020-01'
    end
  end

  describe '#left' do
    let(:model) { FactoryBot.build(:experience, end_date__c: '2020-03-01') }

    pending do
      expect(subject.left).to eq '2020-03'
    end
  end
end
