# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DirectionDecorator do
  subject { described_class.new(model) }
  let(:model) { FactoryBot.build(:direction) }

  describe 'delegations' do
    it do
      is_expected
        .to delegate_method(:client_name).to(:project)
    end
  end

  describe '#status' do
    let(:model) { FactoryBot.build(:direction, status__c: :inprepare) }

    it do
      expect(subject.status).to eq model.status__c
    end
  end

  describe '#direction_month' do
    let(:model) { FactoryBot.build(:direction, directionmonth__c: '対象稼働年月') }

    it do
      expect(subject.direction_month).to eq model.directionmonth__c
    end
  end

  describe '#direction_detail' do
    let(:model) { FactoryBot.build(:direction, directiondetail__c: '業務指示内容') }

    it do
      expect(subject.direction_detail).to eq model.directiondetail__c
    end
  end

  describe '#approved_date_by_fc' do
    let(:model) { FactoryBot.build(:direction, approveddatebyfc__c: Time.current) }

    it do
      expect(subject.approved_date_by_fc).to eq model.approveddatebyfc__c
    end
  end

  describe '#approved_by_fc?' do
    let(:model) { FactoryBot.build(:direction, isapprovedbyfc__c: true) }

    it do
      expect(subject.approved_by_fc?).to eq model.isapprovedbyfc__c
    end
  end
end
