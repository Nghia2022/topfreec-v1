# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkHistory, type: :model do
  describe 'associations' do
    it do
      is_expected.to belong_to(:contact).with_foreign_key(:person__c).with_primary_key(:sfid)
    end
  end

  describe '#owner?' do
    let(:contact) { fc_user.contact }
    let(:work_history) { FactoryBot.build_stubbed(:work_history, contact:) }
    let(:fc_user) { FactoryBot.build_stubbed(:fc_user, :activated) }

    context 'owner' do
      it do
        expect(work_history.owner?(fc_user)).to be_truthy
      end
    end

    context 'not owner' do
      let(:contact) { FactoryBot.build_stubbed(:contact, :fc) }

      it do
        expect(work_history.owner?(fc_user)).to be_falsey
      end
    end
  end

  describe 'scope order_joined' do
    let!(:work_history_a) { FactoryBot.create(:work_history, start_date__c: '2020-10-01') }
    let!(:work_history_b) { FactoryBot.create(:work_history, start_date__c: '2020-08-01') }
    let!(:work_history_c) { FactoryBot.create(:work_history, start_date__c: '2021-01-01') }
    let!(:work_history_d) { FactoryBot.create(:work_history, start_date__c: '2019-10-01') }

    it 'order from newest' do
      expect(WorkHistory.order_joined).to match [work_history_c, work_history_a, work_history_b, work_history_d]
    end
  end
end

# == Schema Information
#
# Table name: salesforce.work_history__c
#
#  id              :integer          not null, primary key
#  _hc_err         :text
#  _hc_lastop      :string(32)
#  company_name__c :string(255)
#  createddate     :datetime
#  end_date__c     :date
#  isdeleted       :boolean
#  name            :string(80)
#  person__c       :string(18)
#  position__c     :string(255)
#  sfid            :string(18)
#  start_date__c   :date
#  status__c       :string(255)
#  systemmodstamp  :datetime
#
# Indexes
#
#  hc_idx_work_history__c_start_date__c   (start_date__c)
#  hc_idx_work_history__c_systemmodstamp  (systemmodstamp)
#  hcu_idx_work_history__c_sfid           (sfid) UNIQUE
#
