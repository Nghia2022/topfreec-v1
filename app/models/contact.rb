# frozen_string_literal: true

class Contact < ApplicationRecord
  include SalesforceHelpers
  self.table_name = 'salesforce.contact'
  self.sobject_name = 'Contact'

  serialize :experienced_works__c, MultiplePicklist
  serialize :experienced_works_main__c, MultiplePicklist
  serialize :experienced_works_sub__c, MultiplePicklist
  serialize :desired_works__c, MultiplePicklist
  serialize :desired_works_main__c, MultiplePicklist
  serialize :desired_works_sub__c, MultiplePicklist
  serialize :experienced_company_size__c, MultiplePicklist
  serialize :work_options__c, MultiplePicklist

  belongs_to :account, foreign_key: :accountid, primary_key: :sfid, optional: true
  has_one :client_user, foreign_key: :contact_sfid, primary_key: :sfid, dependent: :destroy
  has_one :fc_user, foreign_key: :contact_sfid, primary_key: :sfid, dependent: :destroy
  has_many :experiences, foreign_key: :who__c, primary_key: :sfid, dependent: :destroy
  has_many :work_histories, foreign_key: :person__c, primary_key: :sfid, dependent: :destroy

  scope :of_fc_company, -> { joins(:account).merge(Account::FcCompany.all) }
  scope :of_all_fc, -> { joins(:account).merge(Account.all_fc) }
  scope :of_client, -> { joins(:account).merge(Account::Client.all) }

  trigger.after(:update).of(:web_loginemail__c) do
    <<-SQL.squish
    IF NEW.recordtypename__c = 'FC' THEN
      UPDATE fc_users SET email = NEW.web_loginemail__c WHERE fc_users.contact_sfid = NEW.sfid;
    ELSIF NEW.recordtypename__c = 'FC会社' THEN
      UPDATE fc_users SET email = NEW.web_loginemail__c WHERE fc_users.contact_sfid = NEW.sfid;
    ELSIF NEW.recordtypename__c = 'クライアント' THEN
      UPDATE client_users SET email = NEW.web_loginemail__c WHERE client_users.contact_sfid = NEW.sfid;
    END IF
    SQL
  end

  def owner?(user)
    user.contact_sfid == sfid
  end

  def sign_in_allowed_fc?
    account.fcweb_release__c? || Project.of_fc_contact(self).exists?
  end

  def arranged_experiences_work_categories
    WorkCategory.group_sub_categories(experienced_works_sub__c)
  end

  def arranged_desired_work_categories
    WorkCategory.group_sub_categories(desired_works_sub__c)
  end

  def save_commmune_login_datetime
    datetime = Time.zone.now
    update(
      commmune_firstlogindatetime__c: commmune_firstlogindatetime__c.presence || datetime,
      commmune_lastlogindatetime__c:  datetime
    )
  end

  class << self
    def latest_contact_from_sf
      response = restforce.query('select Id from Contact order by CreatedDate desc limit 1')
      contact_id = response.first['Id']
      # Fetch the details of the Contact with the obtained Id
      restforce.find('Contact', contact_id)
    end

    def extract_contact_attributes(salesforce_contact_details)
      {
        sfid:                           salesforce_contact_details['Id'],
        accountid:                      salesforce_contact_details['AccountId'],
        commmune_firstlogindatetime__c: salesforce_contact_details['Commmune_FirstLogindatetime__c'],
        commmune_lastlogindatetime__c:  salesforce_contact_details['Commmune_LastLogindatetime__c'],
        createddate:                    salesforce_contact_details['CreatedDate'],
        desired_works__c:               salesforce_contact_details['Desired_works__c'],
        desired_works_main__c:          salesforce_contact_details['Desired_works_main__c'],
        desired_works_sub__c:           salesforce_contact_details['Desired_works_sub__c'],
        email:                          salesforce_contact_details['Email'],
        existsinheroku__c:              salesforce_contact_details['ExistsInHeroku__c'],
        experienced_company_size__c:    salesforce_contact_details['Experienced_company_size__c'],
        experienced_works__c:           salesforce_contact_details['Experienced_works__c'],
        experienced_works_main__c:      salesforce_contact_details['Experienced_works_main__c'],
        experienced_works_sub__c:       salesforce_contact_details['Experienced_works_sub__c'],
        fcweb_kibou_memo__c:            salesforce_contact_details['FCweb_kibou_memo__c'],
        fcweb_logindatetime__c:         salesforce_contact_details['FCweb_Logindatetime__c'],
        isdeleted:                      salesforce_contact_details['IsDeleted'],
        license__c:                     salesforce_contact_details['License__c'],
        ml_reject__c:                   salesforce_contact_details['ML_Reject__c'],
        recordtypename__c:              salesforce_contact_details['RecordTypeName__c'],
        web_loginemail__c:              salesforce_contact_details['Web_Loginemail__c'],
        work_options__c:                salesforce_contact_details['Work_Options__c'],
        work_prefecture1__c:            salesforce_contact_details['Work_Prefecture1__c'],
        work_prefecture2__c:            salesforce_contact_details['Work_Prefecture2__c'],
        work_prefecture3__c:            salesforce_contact_details['Work_Prefecture3__c']
      }
    end

    def assign_new_contact_from_sf(salesforce_contact_details)
      # Create a new Contact instance
      Contact.new(extract_contact_attributes(salesforce_contact_details))
    end

    def fetch_latest_contacts_from_sf
      salesforce_contact_details = latest_contact_from_sf
      return if Contact.where(sfid: salesforce_contact_details['Id']).any?

      new_contact = assign_new_contact_from_sf(salesforce_contact_details)
      # Save the new Contact record
      if new_contact.save
        # Successfully added the new Contact record
        Rails.logger.debug 'Contact added successfully'
      else
        # Failed to save the Contact record
        Rails.logger.debug 'Failed to add Contact'
        Rails.logger.debug new_contact.errors.full_messages # Display any validation errors
      end
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
