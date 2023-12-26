# frozen_string_literal: true

module Fc::ResetPassword
  # :reek:InstanceVariableAssumption
  class FcUser < ActiveType::Record[FcUser]
    include ResetPassword::Model::ResetPasswordTokenAssertable

    def password_required?
      @skip_confirmation_notification ? false : true
    end

    class << self
      def reset_password_by_token(attributes = {})
        transaction do
          super.tap do |recoverable|
            unless recoverable.activated?
              now = Time.current
              recoverable.update(activated_at: now, activation_token: nil, confirmed_at: now)
            end
          end
        end
      end

      def find_first_by_auth_conditions(attributes)
        found_by_super = super
        return create_from_contact(attributes[:email]) unless found_by_super

        found_by_super if found_by_super.sign_in_allowed_fc?
      end

      def create_from_contact(email)
        contact = Contact.of_all_fc.find_by(web_loginemail__c: email&.downcase)
        return unless contact&.sign_in_allowed_fc?

        now = Time.current
        new(email:, contact:, confirmed_at: now, activated_at: now, &:skip_confirmation_notification!).tap(&:save)
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
