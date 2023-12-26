# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserPasswordMigrator, type: :lib do
  describe '.migrate' do
    let(:fc_user) { FactoryBot.create(:fc_user) }
    let(:cl_user) { FactoryBot.create(:client_user) }

    # rubocop:disable Rails/SkipsModelValidations
    before do
      fc_user.update_columns(encrypted_password: 'pbkdf2_sha256$180000$zZha5LsLz1vQPw7uVLcA$gZ88pqKg1OKOC0urvfc43pfkwVevdKvKZaAgh/24ZlY=')
      cl_user.update_columns(encrypted_password: 'pbkdf2_sha256$180000$LZmb-vAsFbnX7e5Vnrhj$stfGhYnC5tWDL0xRHfTLJa9NYPlRFbPVLpUhKK7yNSw=')
    end
    # rubocop:enable Rails/SkipsModelValidations

    it 'migrates password to new format' do
      UserPasswordMigrator.migrate

      aggregate_failures do
        expect(fc_user.reload).to be_valid_password('password')
          .and have_attributes(password_salt: 'zZha5LsLz1vQPw7uVLcA')
        expect(cl_user.reload).to be_valid_password('password')
          .and have_attributes(password_salt: 'LZmb-vAsFbnX7e5Vnrhj')
      end
    end
  end
end
