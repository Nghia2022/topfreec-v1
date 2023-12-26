# frozen_string_literal: true

class Oauth::Application < Doorkeeper::Application
  attr_encrypted :secret, key: Rails.application.credentials.dig(:oidc, :secret_encrypting_key)

  def self.by_jwt(uid, jwt)
    app = by_uid(uid)
    return unless app
    return app if jwt.blank? && !app.confidential?
    return unless app.jwt_matches?(jwt)

    app
  end

  def jwt_matches?(jwt)
    uid == JWT.decode(jwt, secret, true, { algorithm: 'HS256' }).first['sub']
  rescue JWT::ExpiredSignature, JWT::DecodeError => e
    false
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
