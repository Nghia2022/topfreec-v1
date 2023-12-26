# frozen_string_literal: true

class Oauth::SecretStoring::Plain < Doorkeeper::SecretStoring::Plain
  def self.allows_restoring_secrets?
    false
  end
end
