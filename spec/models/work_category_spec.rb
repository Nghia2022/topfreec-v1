# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkCategory, type: :model do
  describe 'associations' do
    it { should have_many(:project_category_meta) }
  end

  describe '.group_sub_categories' do
    context 'with valid data' do
      subject { described_class.group_sub_categories(%w[PM PMO IT・PM]) }

      it do
        is_expected.to eq(
          {
            'プロジェクト管理' => %w[PM PMO],
            'ITプロジェクト管理' => %w[IT・PM]
          }
        )
      end
    end

    context 'with invalid data' do
      subject { described_class.group_sub_categories(%w[PM PMO IT・PM InvalidData]) }

      it do
        is_expected.to eq(
          {
            'プロジェクト管理' => %w[PM PMO],
            'ITプロジェクト管理' => %w[IT・PM]
          }
        )
      end
    end
  end
end

# == Schema Information
#
# Table name: salesforce.experiencesubcatergory__c
#
#  id                         :integer          not null, primary key
#  _hc_err                    :text
#  _hc_lastop                 :string(32)
#  createddate                :datetime
#  experiencemaincatergory__c :string(255)
#  experiencesubcatergory__c  :string(4099)
#  isdeleted                  :boolean
#  name                       :string(80)
#  sfid                       :string(18)
#  systemmodstamp             :datetime
#
# Indexes
#
#  hc_idx_experiencesubcatergory__c_systemmodstamp  (systemmodstamp)
#  hcu_idx_experiencesubcatergory__c_sfid           (sfid) UNIQUE
#
