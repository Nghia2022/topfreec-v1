# frozen_string_literal: true

class Account < ApplicationRecord
  include SalesforceHelpers

  autoload :Fc, 'account/fc'
  autoload :Client, 'account/client'

  self.table_name = 'salesforce.account'
  self.sobject_name = 'Account'
  self.ignored_columns += [:refusecompany__c]
  acts_as_recordtypable module: Account

  enumerize :recordtypeid, in: { fc: '01228000000PtptAAC', client: '01228000000PthPAAS', fc_company: '01228000000gvWmAAI', master: '012000000000000' }, predicates: true, scope: :shallow

  attribute :saitei_hosyu__c, :integer
  attribute :kibo_hosyu__c, :integer
  attribute :kado_ritsu__c, :integer

  def owner?(user)
    user.contact.accountid == sfid
  end

  class << self
    def latest_account_from_sf
      response = restforce.query('select Id from Account order by CreatedDate desc limit 1')
      account_id = response.first['Id']
      # Fetch the details of the Account with the obtained Id
      restforce.find('Account', account_id)
    end

    def extract_account_attributes(salesforce_account_details)
      {
        sfid: salesforce_account_details.Id,
        client_category__c: salesforce_account_details.Client_Category__c,
        clientcompanyname__c: salesforce_account_details.ClientCompanyName__c,
        clientname__c: salesforce_account_details.ClientName__c,
        consulmasterid__c: salesforce_account_details.ConsulMasterID__c,
        createddate: salesforce_account_details.CreatedDate,
        fcweb_newentrydatetime__c: salesforce_account_details.FCWEB_NewEntryDatetime__c,
        fcweb_release__c: salesforce_account_details.FCweb_release__c,
        isdeleted: salesforce_account_details.IsDeleted,
        ispersonaccount: salesforce_account_details.IsPersonAccount,
        kado_ritsu__c: salesforce_account_details.Kado_Ritsu__c,
        kakunin_bi__c: salesforce_account_details.Kakunin_bi__c,
        kibo_hosyu__c: salesforce_account_details.Kibo_Hosyu__c,
        ng_company__c: salesforce_account_details.NG_Company__c,
        personcontactid: salesforce_account_details.PersonContactId,
        personemail: salesforce_account_details.PersonEmail,
        recordtypeid: salesforce_account_details.RecordTypeId,
        release_yotei__c: salesforce_account_details.Release_Yotei__c,
        release_yotei_kakudo__c: salesforce_account_details.Release_Yotei_Kakudo__c,
        saitei_hosyu__c: salesforce_account_details.Saitei_Hosyu__c,
        systemmodstamp: salesforce_account_details.SystemModstamp,
        web_fcweb_available__c: salesforce_account_details.WEB_FCweb_available__c,
      }
    end

    def assign_new_account_from_sf(salesforce_account_details)
      # Create a new Account instance
      Account.new(extract_account_attributes(salesforce_account_details))
    end

    def fetch_latest_accounts_from_sf
      salesforce_account_details = latest_account_from_sf
      return if Account.where(sfid: salesforce_account_details['Id']).any?
      new_account = assign_new_account_from_sf(salesforce_account_details)
      # Save the new Account record
      if new_account.save
        # Successfully added the new Account record
        Rails.logger.debug 'Account added successfully'
      else
        # Failed to save the Account record
        Rails.logger.debug 'Failed to add Account'
        Rails.logger.debug new_account.errors.full_messages # Display any validation errors
      end
    end

    def all_fc
      [
        fc,
        fc_company
      ].inject(:or)
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
