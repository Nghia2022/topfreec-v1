# frozen_string_literal: true

FactoryBot.define do
  factory :account_fc, class: 'Account::Fc' do
    sfid
    recordtypeid { :fc }
    systemmodstamp { Time.current }
    fcweb_release__c { true }

    trait :valid_data_for_register do
      release_yotei__c { Date.current >> 1 }
      saitei_hosyu__c { 300 }
      kado_ritsu__c { 80 }
      kibo_hosyu__c { 400 }
    end

    trait :unreleased do
      fcweb_release__c { false }
    end
  end

  factory :sf_account_fc, class: 'Restforce::SObject' do
    attributes { { type: 'Account' } }
    add_attribute(:LastName) { Faker::Japanese::Name.last_name }
    add_attribute(:FirstName) { Faker::Japanese::Name.first_name }
    add_attribute(:Name) { "#{send(:LastName)} #{send(:FirstName)}" }
    add_attribute(:Kana__c) { send(:LastName).yomi }
    add_attribute(:Kana_Mei__c) { send(:FirstName).yomi }
    add_attribute(:Phone) { Faker::PhoneNumber.phone_number }
    add_attribute(:Phone2__c) { Faker::PhoneNumber.phone_number }
    add_attribute(:Sex_Select__c) { %w[man woman].sample }
    add_attribute(:BillingPostalCode) { '1500012' }
    add_attribute(:BillingState) { '東京都' }
    add_attribute(:BillingCity) { '渋谷区広尾１丁目１−３９' }
    add_attribute(:BillingStreet) { '恵比寿プライムスクエアタワー4F' }
  end
end

# == Schema Information
#
# Table name: salesforce.account
#
#  id                        :integer          not null, primary key
#  _hc_err                   :text
#  _hc_lastop                :string(32)
#  client_category__c        :string(255)
#  clientcompanyname__c      :string(1300)
#  clientname__c             :string(1300)
#  consulmasterid__c         :string(255)
#  createddate               :datetime
#  fcweb_newentrydatetime__c :datetime
#  fcweb_release__c          :boolean
#  isdeleted                 :boolean
#  ispersonaccount           :boolean
#  kado_ritsu__c             :float
#  kakunin_bi__c             :date
#  kibo_hosyu__c             :float
#  ng_company__c             :text
#  personcontactid           :string(18)
#  personemail               :string(80)
#  recordtypeid              :string(18)
#  release_yotei__c          :date
#  release_yotei_kakudo__c   :string(255)
#  saitei_hosyu__c           :float
#  sfid                      :string(18)
#  systemmodstamp            :datetime
#  web_fcweb_available__c    :datetime
#
# Indexes
#
#  hc_idx_account_ispersonaccount  (ispersonaccount)
#  hc_idx_account_personcontactid  (personcontactid)
#  hc_idx_account_recordtypeid     (recordtypeid)
#  hc_idx_account_systemmodstamp   (systemmodstamp)
#  hcu_idx_account_sfid            (sfid) UNIQUE
#
