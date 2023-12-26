# frozen_string_literal: true

FactoryBot.define do
  factory :oauth_application, class: 'Oauth::Application' do
    name { :fc }
    uid { SecureRandom.hex(32) }
    secret { original_secret }
    original_secret { SecureRandom.hex(32) }
    redirect_uri { 'https://127.0.0.1/callback' }
    scopes { 'openid email' }
    confidential { true }
  end
end

# == Schema Information
#
# Table name: oauth_applications
#
#  id                  :bigint           not null, primary key
#  confidential        :boolean          default(TRUE), not null
#  encrypted_secret    :string
#  encrypted_secret_iv :string
#  name                :string           not null
#  original_secret     :string
#  redirect_uri        :text             not null
#  scopes              :string           default(""), not null
#  uid                 :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_oauth_applications_on_uid  (uid) UNIQUE
#
