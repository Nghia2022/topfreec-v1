# frozen_string_literal: true

module Fc::UserActivation
  class FcUser < ActiveType::Record[FcUser]
    include AfterCommitEverywhere

    validates :contact_sfid, presence: true
    validates_with FcUserActivationValidator

    def password_required?
      false
    end

    # :reek:NilCheck, :reek:TooManyStatements
    def send_activation(contact_sfid) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      transaction do
        raw, encoded_activation_token = Devise.token_generator.generate(self.class, :activation_token)
        contact = Contact.find_by sfid: contact_sfid
        raise ContactNotFound unless contact&.sign_in_allowed_fc?

        if new_record?
          assign_attributes(email: contact.web_loginemail__c)
          skip_confirmation_notification!
        end

        update!(contact:,
                activation_token: encoded_activation_token)
        contact.update!(existsinheroku__c: true)

        after_commit do
          send_activation_instructions(raw)
        end
      rescue ContactNotFound
        errors.add(:contact, :not_found)
        raise
      rescue ActiveRecord::RecordInvalid
        # :nocov:
        raise ActiveRecord::Rollback
        # :nocov:
      end

      errors.empty? && contact.errors.empty?
    end

    def send_activation_instructions(activation_token)
      FcUserMailer.activation_instructions(fc_user: self, activation_token:).deliver_later
    end

    def activate
      now = Time.current
      update(activated_at: now, activation_token: nil, confirmed_at: now)
      send_registration_instructions
    end

    def send_registration_instructions
      # TODO
    end

    class << self
      def activate_by_token(token)
        return new_with_blank_error if token.blank?

        activation_token = Devise.token_generator.digest(self, :activation_token, token)

        record = find_or_initialize_with_error_by(:activation_token, activation_token)
        record.activate if record.persisted?
        record
      end

      private

      def new_with_blank_error
        # :nocov:
        activatable = new
        activatable.errors.add(:activation_token, :blank)
        activatable
        # :nocov:
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
