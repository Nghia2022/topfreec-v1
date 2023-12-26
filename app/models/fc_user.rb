# frozen_string_literal: true

# disable :reek:TooManyMethods
class FcUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :two_factor_authenticatable, :database_authenticatable, :registerable,
         :confirmable, :trackable, :lockable, :timeoutable,
         :recoverable, :rememberable, :secure_validatable,
         :password_expirable,
         :encryptable

  include UserClassifiable
  include Messageable
  include ContactEmailUpdatable
  include TrackFieldsSynchronizable

  belongs_to :contact, foreign_key: :contact_sfid, primary_key: :sfid, optional: true
  has_one :account, class_name: 'Account::Fc', through: :contact
  has_one :person, through: :account
  has_many :access_grants,
           class_name:  'Doorkeeper::AccessGrant',
           foreign_key: :resource_owner_id,
           dependent:   :delete_all

  has_many :access_tokens,
           class_name:  'Oauth::AccessToken',
           foreign_key: :resource_owner_id,
           dependent:   :delete_all

  scope :unactivated, -> { where(contact_sfid: nil) }

  delegate :account, :sign_in_allowed_fc?, to: :contact, allow_nil: true
  delegate :name, to: :class, prefix: true

  has_one_time_password(encrypted: true)

  validates :contact_sfid, uniqueness: { allow_blank: true }

  strip_attributes only: %i[contact_sfid]

  class << self
    def send_reset_password_instructions(attributes = {})
      recoverable = find_or_initialize_with_errors(reset_password_keys, attributes, :not_found)
      recoverable.send_reset_password_instructions if recoverable.persisted? && recoverable.sign_in_allowed_fc?
      recoverable
    end
  end

  def devise_mailer
    FcUserMailer
  end

  def need_two_factor_authentication?(_request)
    false
  end

  def send_two_factor_authentication_code(code)
    FcUserSmsMailer.two_factor(self, code).deliver_later
  end

  def phone
    sf_contact.Phone
  end

  def unconfirmed_phone
    sf_contact.PhoneForConfirmation__c
  end

  def sf_contact
    @sf_contact ||= contact.to_sobject
  end

  def phone_to_send_otp
    unconfirmed_phone || phone
  end

  def phone_normalized
    PhonyRails.normalize_number phone_to_send_otp, country_code: 'JP' if phone_to_send_otp.present?
  end

  # TODO: ConsulMasterID__cが発行されていることをチェックする
  def activated?
    activated_at? && contact_sfid?
  end

  def registration_completed?
    registration_completed_at? || fc_company?
  end

  def account_cache_key_with_version
    @account_cache_key_with_version ||= account&.cache_key_with_version
  end

  # NOTE: 仕様未確定の暫定実装
  def browsing_histories
    Project.browsing_histories_with_user(self)
  end

  def switch_user_label
    email + kind_label.to_s
  end

  def kind_label
    if fc?
      '(FC)'
    elsif fc_company?
      '(FC会社)'
    end
  end

  rails_admin do
    exclude_fields :account_id
  end

  def active_for_authentication?
    sign_in_allowed_fc?
  end

  private

  def restforce
    @restforce ||= RestforceFactory.new_client
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
