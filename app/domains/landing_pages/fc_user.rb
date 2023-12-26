# frozen_string_literal: true

module LandingPages
  class FcUser < ActiveType::Record[FcUser]
    def password_required?
      false
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
