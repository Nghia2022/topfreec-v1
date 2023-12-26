# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LandingPages::FcUser, type: :model do
  describe '#password_required?' do
    it do
      is_expected.to_not be_password_required
    end
  end
end

# == Schema Information
#
# Table name: users
#
#  id                            :bigint           not null, primary key
#  confirmation_sent_at          :datetime
#  confirmation_token            :string
#  confirmed_at                  :datetime
#  current_sign_in_at            :datetime
#  current_sign_in_ip            :inet
#  direct_otp                    :string
#  direct_otp_sent_at            :datetime
#  email                         :string           default(""), not null
#  encrypted_otp_secret_key      :string
#  encrypted_otp_secret_key_iv   :string
#  encrypted_otp_secret_key_salt :string
#  encrypted_password            :string           default(""), not null
#  last_sign_in_at               :datetime
#  last_sign_in_ip               :inet
#  lead_sfid                     :string
#  remember_created_at           :datetime
#  reset_password_sent_at        :datetime
#  reset_password_token          :string
#  second_factor_attempts_count  :integer          default(0)
#  sign_in_count                 :integer          default(0), not null
#  totp_timestamp                :datetime
#  unconfirmed_email             :string
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  account_id                    :integer
#
# Indexes
#
#  index_users_on_account_id                (account_id)
#  index_users_on_confirmation_token        (confirmation_token) UNIQUE
#  index_users_on_email                     (email) UNIQUE
#  index_users_on_encrypted_otp_secret_key  (encrypted_otp_secret_key) UNIQUE
#  index_users_on_lead_sfid                 (lead_sfid)
#  index_users_on_reset_password_token      (reset_password_token) UNIQUE
#
