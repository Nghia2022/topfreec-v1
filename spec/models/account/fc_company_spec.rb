# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account::FcCompany, type: :model do
  describe 'associations' do
    it do
      is_expected.to have_many(:contacts).with_foreign_key(:accountid).with_primary_key(:sfid)
    end
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
