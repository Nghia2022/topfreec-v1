# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Oauth::Application, type: :model do
  let(:oauth_application) { FactoryBot.create(:oauth_application) }

  describe '#secret' do
    subject { oauth_application.secret }
    it { is_expected.to eq oauth_application.original_secret }
  end

  describe '#encrypted_secret' do
    subject { oauth_application.encrypted_secret }
    it { is_expected.not_to eq oauth_application.original_secret }
    it { is_expected.not_to be_blank }
  end

  describe '.by_jwt' do
    subject { described_class.by_jwt(uid, jwt) }

    let(:uid) { oauth_application.uid }
    let(:timestamp) { Time.zone.now.to_i }
    let(:assertions) do
      {
        iat: timestamp,
        exp: timestamp + 1.minute.to_i,
        jti: SecureRandom.uuid,
        iss: uid,
        sub: uid
      }
    end
    let(:jwt) { JWT.encode(assertions, oauth_application.secret, 'HS256') }

    it { is_expected.to eq oauth_application }

    context 'when uid is invalid' do
      subject { described_class.by_jwt(SecureRandom.hex(32), jwt) }
      it { is_expected.to eq nil }
    end

    context 'when jwt is blank and confidential is false' do
      let(:oauth_application) { FactoryBot.create(:oauth_application, confidential: false) }
      let(:jwt) { nil }
      it { is_expected.to eq oauth_application }
    end
  end

  describe '#jwt_matches?' do
    subject { oauth_application.jwt_matches?(jwt) }

    let(:uid) { oauth_application.uid }
    let(:timestamp) { Time.zone.now.to_i }
    let(:assertions) do
      {
        iat: timestamp,
        exp: timestamp + 1.minute.to_i,
        jti: SecureRandom.uuid,
        iss: uid,
        sub: uid
      }
    end
    let(:jwt) { JWT.encode(assertions, oauth_application.secret, 'HS256') }

    describe 'jwt' do
      describe 'sub' do
        context 'with valid' do
          let(:uid) { oauth_application.uid }
          it { is_expected.to be_truthy }
        end

        context 'with invalid' do
          let(:uid) { 'another-uid' }
          it { is_expected.to be_falsey }
        end
      end

      describe 'exp' do
        context 'with valid' do
          let(:timestamp) { Time.zone.now.to_i }
          it { is_expected.to be_truthy }
        end

        context 'with invalid' do
          let(:timestamp) { Time.zone.now.to_i - 1.minute.to_i }
          it { is_expected.to be_falsey }
        end
      end
    end
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
