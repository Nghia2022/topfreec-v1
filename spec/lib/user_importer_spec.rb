# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserImporter, type: :lib do
  describe '.imort_from_csv' do
    context 'with users with passwords' do
      it do
        UserImporter.import_from_csv(file_fixture('users.csv'))

        fc_user = FcUser.find_by!(email: 'test1@mirai-works.co.jp')
        cl_user = ClientUser.find_by!(email: 'test2@mirai-works.co.jp')

        aggregate_failures do
          expect(fc_user).to be_valid_password('5sDqrENXhtF')
            .and have_attributes(password_salt: 'qIGcAVQRka3E')
            .and be_confirmed
            .and be_activated

          expect(cl_user).to be_valid_password('samplesample')
            .and have_attributes(password_salt: 'eTsctfOVBCV6')
            .and be_confirmed
        end
      end
    end

    context 'when users are empty' do
      it do
        expect do
          UserImporter.import_from_csv(file_fixture('users-empty.csv'))
        end.to raise_no_error
          .and not_change(FcUser, :count)
          .and not_change(ClientUser, :count)
      end
    end
  end
end
