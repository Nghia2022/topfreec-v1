# frozen_string_literal: true

FactoryBot.define do
  factory :contact do
    sfid
    web_loginemail__c { Faker::Internet.email }
    email { web_loginemail__c }
    existsinheroku__c { false }

    transient do
      account_fc_trait { [] }
      account_client_trait { [] }
    end

    trait :fc do
      account { association(:account_fc, *(account_fc_trait.to_a + [person: instance])) }
      recordtypename__c { 'FC' }
    end

    trait :fc_company do
      account { association(:account_fc_company, *account_fc_trait) }
      recordtypename__c { 'FC会社' }
    end

    trait :client do
      account { association(:account_client, *account_client_trait) }
      recordtypename__c { 'クライアント' }
    end

    trait :valid_data_for_register do
      account_fc_trait { [:valid_data_for_register] }
      experienced_works__c { %w[PM/PMO 人事/組織設計] }
      experienced_works_main__c { %w[ITプロジェクト管理 新規事業] }
      experienced_works_sub__c { %w[IT・PM IT・PMO 事業開発（企画）] }
      desired_works__c { %w[新規事業/IPO 営業 セキュリティ] }
      desired_works_main__c { %w[ITプロジェクト管理 新規事業] }
      desired_works_sub__c { %w[IT・PM IT・PMO 事業開発（企画）] }
      experienced_company_size__c { %w[中小 ベンチャー] }
      work_prefecture1__c { '青森県' }
      work_prefecture2__c { '沖縄県' }
      work_prefecture3__c { '長野県' }
      work_options__c { %w[完全出社 完全リモート] }
      fcweb_kibou_memo__c { 'メモ' }
    end
  end

  factory :sf_contact, class: 'Restforce::SObject' do
    attributes { { type: 'Contact' } }
    add_attribute(:Email) { Faker::Internet.email }
    add_attribute(:Web_LoginEmail__c) { Faker::Internet.email }
    add_attribute(:LastName) { Faker::Japanese::Name.last_name }
    add_attribute(:FirstName) { Faker::Japanese::Name.first_name }
    add_attribute(:Kana_Sei__c) { send(:LastName).yomi }
    add_attribute(:Kana_Mei__c) { send(:FirstName).yomi }
    add_attribute(:Name) { "#{send(:LastName)} #{send(:FirstName)}" }
    add_attribute(:Phone) { Faker::PhoneNumber.cell_phone.delete('-') }
    add_attribute(:HomePhone) { Faker::PhoneNumber.phone_number.delete('-') }
    add_attribute(:MailingPostalCode) { '1500012' }
    add_attribute(:MailingState) { '東京都' }
    add_attribute(:MailingCity) { '渋谷区広尾１丁目１−３９' }
    add_attribute(:MailingStreet) { '恵比寿プライムスクエアタワー4F' }

    trait :fc do
      # NOOP
    end
  end
end

# == Schema Information
#
# Table name: salesforce.contact
#
#  id                             :integer          not null, primary key
#  _hc_err                        :text
#  _hc_lastop                     :string(32)
#  accountid                      :string(18)
#  commmune_firstlogindatetime__c :datetime
#  commmune_lastlogindatetime__c  :datetime
#  createddate                    :datetime
#  desired_works__c               :string(4099)
#  desired_works_main__c          :string(4099)
#  desired_works_sub__c           :string(4099)
#  email                          :string(80)
#  existsinheroku__c              :boolean
#  experienced_company_size__c    :string(4099)
#  experienced_works__c           :string(4099)
#  experienced_works_main__c      :string(4099)
#  experienced_works_sub__c       :string(4099)
#  fcweb_kibou_memo__c            :string(1200)
#  fcweb_logindatetime__c         :datetime
#  isdeleted                      :boolean
#  license__c                     :string(500)
#  ml_reject__c                   :boolean
#  recordtypename__c              :string(1300)
#  sfid                           :string(18)
#  systemmodstamp                 :datetime
#  web_loginemail__c              :string(80)
#  work_options__c                :string(4099)
#  work_prefecture1__c            :string(255)
#  work_prefecture2__c            :string(255)
#  work_prefecture3__c            :string(255)
#
# Indexes
#
#  hc_idx_contact_accountid          (accountid)
#  hc_idx_contact_systemmodstamp     (systemmodstamp)
#  hc_idx_contact_web_loginemail__c  (web_loginemail__c)
#  hcu_idx_contact_sfid              (sfid) UNIQUE
#
