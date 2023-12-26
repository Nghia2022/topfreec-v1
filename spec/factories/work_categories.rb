# frozen_string_literal: true

FactoryBot.define do
  factory :work_category do
    sfid
    name { 'プロジェクト管理' }
    experiencemaincatergory__c { 'プロジェクト管理' }
    experiencesubcatergory__c { ['PM', 'PMO', 'プロジェクトサポート/補佐', 'その他（プロジェクト管理）'] }
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
