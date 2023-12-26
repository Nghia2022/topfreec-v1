# frozen_string_literal: true

class UserImporter
  class ClientUser < ::ClientUser
    # :nocov:
    def password_required?
      false
    end
    # :nocov:
  end

  class FcUser < ::FcUser
    # :nocov:
    def password_required?
      false
    end
    # :nocov:
  end

  class << self
    def import_from_csv(file_path)
      ApplicationRecord.transaction do
        now = Time.current
        data = [[], []]

        CSV.foreach(file_path, headers: true, skip_blanks: true) do |row|
          data[row['is_fc'].to_i] << row_to_columns(now, row)
        end

        # rubocop:disable Rails/SkipsModelValidations
        [ClientUser, FcUser].each_with_index do |model, index|
          records = data[index].to_a
          next if records.empty?

          model.insert_all!(records)
        end
        # rubocop:enable Rails/SkipsModelValidations
      end
    end

    private

    def row_to_columns(now, row)
      base_timestamps = { created_at: now, updated_at: now, confirmed_at: now }
      timestamps = if row['is_fc'].to_i.positive?
                     base_timestamps.merge(activated_at: now)
                   else
                     base_timestamps
                   end
      password = row['password'].split('$')

      {
        email:              row['email'],
        password_salt:      password.slice!(2),
        encrypted_password: password.join('$'),
        contact_sfid:       row['sfdcid']
      }.merge(timestamps)
    end
  end
end
