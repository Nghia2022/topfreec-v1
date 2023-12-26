# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClientUser, type: :model do
  describe 'devise modules' do
    it do
      expect(described_class.ancestors).to [
        include(Devise::Models::DatabaseAuthenticatable,
                Devise::Models::Confirmable,
                Devise::Models::Trackable,
                Devise::Models::Lockable,
                Devise::Models::Timeoutable,
                Devise::Models::Recoverable,
                Devise::Models::Rememberable,
                Devise::Models::SecureValidatable,
                Devise::Models::Encryptable)
      ].inject(:and)
    end

    describe 'lockable' do
      it do
        expect(described_class).to have_attributes(
          lock_strategy:    :failed_attempts,
          unlock_strategy:  :time,
          maximum_attempts: 10,
          unlock_in:        30.minutes
        )
      end
    end

    describe 'timeoutable' do
      it do
        expect(described_class).to have_attributes(
          timeout_in: 3.hours
        )
      end
    end

    describe 'secure_validatable' do
      it do
        expect(described_class).to have_attributes(
          password_length: 8..128
        )
      end
    end
  end

  describe 'associations' do
    describe '#contact' do
      it do
        is_expected.to belong_to(:contact).with_foreign_key(:contact_sfid).with_primary_key(:sfid).optional
      end
    end
  end

  describe 'delegations' do
    subject { FactoryBot.build(:client_user) }

    it do
      is_expected.to delegate_method(:account).to(:contact).allow_nil
        .and delegate_method(:name).to(:class).with_prefix
    end
  end

  describe '#fc?' do
    subject { FactoryBot.build(:client_user, :with_contact) }

    it do
      is_expected.not_to be_fc
    end
  end

  describe '#fc_company?' do
    subject { FactoryBot.build(:client_user, :with_contact) }

    it do
      is_expected.not_to be_fc_company
    end
  end

  describe '#client?' do
    subject { FactoryBot.build(:client_user, :with_contact) }

    it do
      is_expected.to be_client
    end
  end

  describe '#encrypted_password' do
    let(:user) { FactoryBot.create(:client_user, :with_contact) }
    let(:password) { 'password' }
    let(:sf_contact) { FactoryBot.build_stubbed(:sf_contact) }

    before do
      allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
      user.update(password:)
    end

    it 'uses custom encryptor' do
      expect(user.encrypted_password).to match('pbkdf2_sha256')
      expect(user.valid_password?(password)).to be true
    end
  end
end

# == Schema Information
#
# Table name: client_users
#
#  id                     :bigint           not null, primary key
#  account_sfid           :string
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  contact_sfid           :string
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  failed_attempts        :integer          default(0), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  locked_at              :datetime
#  password_changed_at    :datetime
#  password_salt          :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  unconfirmed_email      :string
#  user_agent             :string           default(""), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_client_users_on_account_sfid          (account_sfid)
#  index_client_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_client_users_on_email                 (email) UNIQUE
#  index_client_users_on_reset_password_token  (reset_password_token) UNIQUE
#
