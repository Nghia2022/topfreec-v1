# frozen_string_literal: true

module Fc::UserRegistration
  class FcUser < ActiveType::Record[FcUser]
    include Confirming
    extend Enumerize

    attribute :last_name, :string
    attribute :first_name, :string
    attribute :last_name_kana, :string
    attribute :first_name_kana, :string
    attribute :phone, :string
    attribute :work_location1, :string
    attribute :work_location2, :string
    attribute :work_location3, :string
    attribute :session_id, :string
    attribute :user_agent, :string

    WORK_LOCATIONS = %w[関東（一都三県） 関東（一都三県以外） 近畿 その他（国内） その他（海外）].freeze
    VALID_PHONE_REGEX = /\A\d{10,11}\z/
    LP_CODE = 'FCWeb'

    validates :last_name, presence: true
    validates :first_name, presence: true
    validates :last_name_kana, presence: true
    validates :first_name_kana, presence: true
    validates :phone, presence: true, format: { with: VALID_PHONE_REGEX }

    validates :work_location1, presence: true
    validates :work_location2, absence: { if: -> { work_location1.blank? } }
    validates :work_location3, absence: { if: -> { work_location2.blank? } }

    enumerize :work_location1, in: WORK_LOCATIONS
    enumerize :work_location2, in: WORK_LOCATIONS
    enumerize :work_location3, in: WORK_LOCATIONS

    before_create :create_lead_in_salesforce

    def password_required?
      false
    end

    private

    def create_lead_in_salesforce
      lead = Salesforce::Lead.find_or_create_by(salesforce_params)
      self.lead_sfid = lead.Id
      self.lead_no = lead.LeadId__c
    end

    def work_location__c
      res = "1-#{work_location1_text}"
      res += " , 2-#{work_location2_text}" if work_location2.present?
      res += " , 3-#{work_location3_text}" if work_location3.present?
      res
    end

    def salesforce_params
      {
        LastName:                        last_name,
        firstName:                       first_name,
        Kana_Sei__c:                     last_name_kana,
        Kana_Mei__c:                     first_name_kana,
        Email:                           email,
        Phone:                           phone,
        WorkLocation__c:                 work_location__c,
        lp_code__c:                      LP_CODE,
        Career_Declaration_Confirmed__c: true,
        Agreement1__c:                   true,
        Agreement3__c:                   true,
        AD_EBiS_member_name__c:          session_id,
        LeadSource:                      'Web',
        user_agent__c:                   user_agent_type
      }
    end

    def user_agent_type
      if user_agent.to_s.match?(/iPhone|iPad|iPod|Android/)
        'SP'
      else
        'PC'
      end
    end
  end
end

# == Schema Information
#
# Table name: fc_users
#
#  id                            :bigint           not null, primary key
#  account_sfid                  :string
#  activated_at                  :datetime
#  activation_token              :string
#  confirmation_sent_at          :datetime
#  confirmation_token            :string
#  confirmed_at                  :datetime
#  contact_sfid                  :string
#  current_sign_in_at            :datetime
#  current_sign_in_ip            :inet
#  direct_otp                    :string
#  direct_otp_sent_at            :datetime
#  email                         :string           default(""), not null
#  encrypted_otp_secret_key      :string
#  encrypted_otp_secret_key_iv   :string
#  encrypted_otp_secret_key_salt :string
#  encrypted_password            :string           default(""), not null
#  failed_attempts               :integer          default(0), not null
#  last_sign_in_at               :datetime
#  last_sign_in_ip               :inet
#  lead_no                       :string
#  lead_sfid                     :string
#  locked_at                     :datetime
#  password_changed_at           :datetime
#  password_salt                 :string
#  profile_image                 :string
#  registration_completed_at     :datetime
#  remember_created_at           :datetime
#  reset_password_sent_at        :datetime
#  reset_password_token          :string
#  second_factor_attempts_count  :integer          default(0)
#  sign_in_count                 :integer          default(0), not null
#  totp_timestamp                :datetime
#  unconfirmed_email             :string
#  user_agent                    :string           default(""), not null
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  account_id                    :integer
#
# Indexes
#
#  index_fc_users_on_account_id                (account_id)
#  index_fc_users_on_account_sfid              (account_sfid)
#  index_fc_users_on_activation_token          (activation_token) UNIQUE
#  index_fc_users_on_confirmation_token        (confirmation_token) UNIQUE
#  index_fc_users_on_contact_sfid              (contact_sfid) UNIQUE
#  index_fc_users_on_email                     (email) UNIQUE
#  index_fc_users_on_encrypted_otp_secret_key  (encrypted_otp_secret_key) UNIQUE
#  index_fc_users_on_lead_no                   (lead_no) UNIQUE
#  index_fc_users_on_lead_sfid                 (lead_sfid)
#  index_fc_users_on_reset_password_token      (reset_password_token) UNIQUE
#
