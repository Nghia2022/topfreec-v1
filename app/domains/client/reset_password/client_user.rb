# frozen_string_literal: true

module Client::ResetPassword
  # :reek:InstanceVariableAssumption
  class ClientUser < ActiveType::Record[ClientUser]
    include ResetPassword::Model::ResetPasswordTokenAssertable

    def password_required?
      @skip_confirmation_notification ? false : true
    end

    class << self
      def find_first_by_auth_conditions(attributes)
        super || create_from_contact(attributes[:email])
      end

      def create_from_contact(email)
        contact = Contact.of_client.find_by(web_loginemail__c: email&.downcase)
        return unless contact

        new(email:, contact:, confirmed_at: Time.current, &:skip_confirmation_notification!).tap(&:save)
      end
    end
  end
end

# == Schema Information
#
# Table name: client_users
#
#  id                     :bigint           not null, primary key
#  account_sfid           :string
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  contact_sfid           :string
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  failed_attempts        :integer          default(0), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  locked_at              :datetime
#  password_changed_at    :datetime
#  password_salt          :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  unconfirmed_email      :string
#  user_agent             :string           default(""), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_client_users_on_account_sfid          (account_sfid)
#  index_client_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_client_users_on_email                 (email) UNIQUE
#  index_client_users_on_reset_password_token  (reset_password_token) UNIQUE
#
