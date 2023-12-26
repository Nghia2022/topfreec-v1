# frozen_string_literal: true

module Devise
  module Encryptable
    module Encryptors
      class Pbkdf2Django2 < Base
        def self.digest(password, stretches, salt, _pepper)
          hash = Base64.encode64(OpenSSL::PKCS5.pbkdf2_hmac(password, salt, stretches, 32, 'sha256')).strip
          ['pbkdf2_sha256', stretches, hash].join('$')
        end

        def self.compare(encrypted_password, password, _stretches, salt, _pepper)
          stretches = encrypted_password.split('$')[1]
          Devise.secure_compare(encrypted_password, digest(password, stretches.to_i, salt, nil))
        end
      end
    end
  end
end
