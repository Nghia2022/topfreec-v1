# frozen_string_literal: true

class UserPasswordMigrator
  class << self
    def migrate
      ApplicationRecord.transaction do
        [ClientUser, FcUser].each { |model| migrate_password_format(model) }
      end
    end

    private

    def migrate_password_format(model)
      model.find_each do |user|
        encryptor, stretches, salt, hash = user.encrypted_password.split('$')
        user.update_columns(encrypted_password: [encryptor, stretches, hash].join('$'), password_salt: salt) # rubocop:disable Rails/SkipsModelValidations
      end
    end
  end
end
