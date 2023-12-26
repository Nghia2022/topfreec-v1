# frozen_string_literal: true

namespace :oneshot do
  task clear_unchanged_password: :environment do
    # rubocop:disable Rails/SkipsModelValidations
    FcUser.where(password_changed_at: nil).update_all(encrypted_password: '')
    ClientUser.where(password_changed_at: nil).update_all(encrypted_password: '')
    # rubocop:enable Rails/SkipsModelValidations
  end
end
