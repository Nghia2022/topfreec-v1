# frozen_string_literal: true

module WpUsers
  class SignIn < ActiveType::Record[Wordpress::WpUser]
    attribute :password, :string
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
