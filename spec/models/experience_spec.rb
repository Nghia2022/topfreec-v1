# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Experience, type: :model do
  it_behaves_like 'sobject', 'Experience__c'

  describe 'associations' do
    it do
      is_expected.to belong_to(:project).with_foreign_key(:opportunity__c).with_primary_key(:sfid).optional
      is_expected.to belong_to(:contact).with_foreign_key(:who__c).with_primary_key(:sfid).optional
    end
  end

  describe '#close' do
    context 'if experience is published' do
      let(:experience) { FactoryBot.create(:experience, :published) }

      it 'should be close' do
        expect do
          experience.close
        end.to change { experience.reload.openflag__c }.from(true).to(false)
      end
    end
  end

  describe '#publish' do
    context 'if experience is closed' do
      let(:experience) { FactoryBot.create(:experience, :closed) }

      it 'should be publish' do
        expect do
          experience.publish
        end.to change { experience.reload.openflag__c }.from(false).to(true)
      end
    end
  end

  describe '.oldest' do
    let!(:contact) { FactoryBot.create(:contact) }
    let!(:experiences) do
      [
        FactoryBot.create(:experience, contact:, start_date__c: '2020-04-05'),
        FactoryBot.create(:experience, contact:, start_date__c: '2020-04-01'),
        FactoryBot.create(:experience, contact:, start_date__c: '2020-03-01')
      ].reverse
    end

    it do
      expect(Experience.oldest).to eq(experiences)
    end
  end

  describe '#owner?' do
    let(:user) { FactoryBot.build(:fc_user, :activated) }
    let(:experience) { FactoryBot.build(:experience, contact: user.contact) }

    it do
      expect(experience.owner?(user)).to be_truthy
    end
  end
end

# == Schema Information
#
# Table name: salesforce.experience__c
#
#  id               :integer          not null, primary key
#  _hc_err          :text
#  _hc_lastop       :string(32)
#  activeflag__c    :boolean
#  createddate      :datetime
#  detail_mws__c    :string(5000)
#  details_self__c  :string(5000)
#  end_date__c      :date
#  isdeleted        :boolean
#  member_amount__c :float
#  name             :string(80)
#  openflag__c      :boolean
#  opportunity__c   :string(18)
#  organization__c  :string(255)
#  position__c      :string(255)
#  recordtypeid     :string(18)
#  sfid             :string(18)
#  start_date__c    :date
#  systemmodstamp   :datetime
#  who__c           :string(18)
#
# Indexes
#
#  hc_idx_experience__c_systemmodstamp  (systemmodstamp)
#  hcu_idx_experience__c_sfid           (sfid) UNIQUE
#
