# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Fc::Settings::ProjectRequestForm, type: :model do
  describe 'validations' do
    let(:attributes) { {} }
    subject { described_class.new(attributes) }

    describe '#reward_min' do
      it do
        is_expected.to allow_value(0, 123, 999).for(:reward_min)
          .and not_allow_value(-1).for(:reward_min)
          .and not_allow_value(1000).for(:reward_min)
          .and not_allow_value('a').for(:reward_min)
          .and not_allow_value('').for(:reward_min)
      end
    end

    describe '#reward_desired' do
      it do
        is_expected.to allow_value(0, 123, 999).for(:reward_desired)
          .and not_allow_value(-1).for(:reward_desired)
          .and not_allow_value(1000).for(:reward_desired)
          .and not_allow_value('').for(:reward_desired)
      end
    end

    describe '#occupancy_rate' do
      it do
        is_expected
          .to validate_presence_of(:occupancy_rate)
      end
    end

    describe '#start_timing' do
      it do
        is_expected
          .to validate_presence_of(:start_timing)
      end

      context 'invalid' do
        subject { described_class.new(start_timing: 1.day.ago) }

        it do
          subject.valid?
          expect(subject.errors[:start_timing]).to include('は現在より未来の日付を選択してください')
        end
      end
    end
  end

  describe '#save' do
    let(:form) { described_class.new }
    let(:fc_user) { FactoryBot.create(:fc_user, :activated, contact_trait: :valid_data_for_register) }
    let(:contact) { fc_user.contact }
    let(:account) { contact.account }
    let(:valid_params) do
      {
        occupancy_rate: 80,
        reward_min:     10
      }
    end
    let(:params) { valid_params }

    before do
      stub_salesforce_request
      form.assign_attributes(params)
    end

    context 'when start_timing and reward_desired are not changed' do
      let(:params) do
        { start_timing: account.release_yotei__c, reward_desired: account.kibo_hosyu__c }
      end

      it do
        expect do
          form.save(contact)
        end.to(not_change { account.reload.kakunin_bi__c })
      end
    end

    context 'when start_timing is changed' do
      let(:contact_trait) { :valid_data_for_register }
      let(:params) do
        { **valid_params, start_timing: Date.current, reward_desired: account.kibo_hosyu__c }
      end

      it do
        expect do
          form.save(contact)
        end.to(change { account.reload.kakunin_bi__c }.from(nil).to(Date.current))
      end
    end

    context 'when reward_desired is changed' do
      let(:contact_trait) { :valid_data_for_register }
      let(:params) do
        { **valid_params, start_timing: account.release_yotei__c, reward_desired: 100 }
      end

      it do
        expect do
          form.save(contact)
        end.to(change { account.reload.kakunin_bi__c }.from(nil).to(Date.current))
      end
    end
  end
end
