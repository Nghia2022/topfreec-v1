# frozen_string_literal: true

class Wordpress::WpUser < ApplicationRecord
  include UserClassifiable

  establish_connection :wordpress

  self.table_name = 'wp_users'

  def valid_password?(password)
    Phpass.new.check(password, user_pass)
  end

  def authenticatable_salt
    user_pass.slice(0, 12)
  end

  # disable :reek:UtilityFunction
  # :nocov:
  def receipts
    Receipt.none
  end
  # :nocov:

  def account
    nil
  end

  class << self
    def find_for_authentication(conditions)
      find_by(user_login: conditions[:user_login])
    end

    def serialize_into_session(record)
      [record.id, record.authenticatable_salt]
    end

    # disable :reek:ControlParameter, :reek:UtilityFunction
    # :nocov:
    def serialize_from_session(key, salt)
      record = to_adapter.get(key)
      record if record && record.authenticatable_salt == salt
    end
    # :nocov:

    def authentication_keys
      %i[user_login]
    end
  end
end

# == Schema Information
#
# Table name: wp_users
#
#  ID                  :bigint           unsigned, not null, primary key
#  display_name        :string(250)      default(""), not null
#  user_activation_key :string(255)      default(""), not null
#  user_email          :string(100)      default(""), not null
#  user_login          :string(60)       default(""), not null
#  user_nicename       :string(50)       default(""), not null
#  user_pass           :string(255)      default(""), not null
#  user_registered     :datetime         default(NULL), not null
#  user_status         :integer          default(0), not null
#  user_url            :string(100)      default(""), not null
#
# Indexes
#
#  user_email      (user_email)
#  user_login_key  (user_login)
#  user_nicename   (user_nicename)
#
