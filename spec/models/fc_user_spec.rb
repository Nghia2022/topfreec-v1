# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FcUser, type: :model do
  describe 'devise modules' do
    it do
      expect(described_class.ancestors).to [
        include(Devise::Models::DatabaseAuthenticatable,
                Devise::Models::Registerable,
                Devise::Models::Confirmable,
                Devise::Models::Trackable,
                Devise::Models::Lockable,
                Devise::Models::Timeoutable,
                Devise::Models::Recoverable,
                Devise::Models::Rememberable,
                Devise::Models::SecureValidatable,
                Devise::Models::PasswordExpirable,
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
    it { is_expected.to belong_to(:contact).optional }
    it { is_expected.to have_one(:account).through(:contact) }
    it { is_expected.to have_one(:person).through(:account) }
    it { is_expected.to have_many(:access_grants) }
    it { is_expected.to have_many(:access_tokens) }
  end

  describe 'strip_attributes' do
    it { is_expected.to strip_attribute(:contact_sfid) }
  end

  describe 'validations' do
    subject { FactoryBot.build(:fc_user) }

    it do
      is_expected.to validate_presence_of(:email).with_message('メールアドレスを入力してください')
    end

    it do
      is_expected.to validate_uniqueness_of(:email).allow_blank.case_insensitive.with_message('メールアドレスが利用できません。')
    end

    it do
      is_expected.to validate_presence_of(:password).with_message('パスワードを入力してください')
        .and validate_confirmation_of(:password).with_message('新しいパスワード（確認）が一致しません')
        .and validate_length_of(:password).with_message('パスワードが短すぎます')
    end

    it do
      is_expected.to validate_uniqueness_of(:contact_sfid)
    end
  end

  describe 'scopes' do
    describe '.unactivated' do
      named_let!(:activated_fc_user) { FactoryBot.create(:fc_user, :activated) }
      named_let!(:unactivated_fc_user) { FactoryBot.create(:fc_user, :unactivated) }

      it do
        expect(FcUser.unactivated).to not_include(activated_fc_user)
          .and include(unactivated_fc_user)
      end
    end
  end

  describe '#switch_user_label' do
    let(:fc_user) { FactoryBot.build(:fc_user) }
    let(:kind_label) { fc_user.kind_label }
    let(:email) { fc_user.email }

    it do
      expect(fc_user.switch_user_label).to eq(email + kind_label.to_s)
    end
  end

  describe '#fc?' do
    subject { FactoryBot.create(:fc_user, contact:) }
    let(:kind_label) { subject.kind_label }

    context 'when fc' do
      let(:contact) { FactoryBot.build(:contact, :fc) }

      it do
        is_expected.to be_fc
      end

      it do
        expect(kind_label).to eq('(FC)')
      end
    end

    context 'when fc company' do
      let(:contact) { FactoryBot.build(:contact, :fc_company) }

      it do
        is_expected.not_to be_fc
      end

      it do
        expect(kind_label).to eq('(FC会社)')
      end
    end
  end

  describe '#fc_company?' do
    subject { FactoryBot.build(:fc_user, contact:) }
    let(:kind_label) { subject.kind_label }

    context 'when fc' do
      let(:contact) { FactoryBot.build(:contact, :fc) }

      it do
        is_expected.not_to be_fc_company
      end

      it do
        expect(kind_label).to eq('(FC)')
      end
    end

    context 'when fc company' do
      let(:contact) { FactoryBot.build(:contact, :fc_company) }

      it do
        is_expected.to be_fc_company
      end

      it do
        expect(kind_label).to eq('(FC会社)')
      end
    end
  end

  describe '#client?' do
    subject { FactoryBot.build(:fc_user, contact:) }

    context 'when fc' do
      let(:contact) { FactoryBot.build(:contact, :fc) }
      it do
        is_expected.not_to be_client
      end
    end

    context 'when fc company' do
      let(:contact) { FactoryBot.build(:contact, :fc_company) }

      it do
        is_expected.not_to be_client
      end
    end
  end

  describe '#encrypted_password' do
    let(:user) { FactoryBot.create(:fc_user, :activated) }
    let(:password) { 'p@sSw0rd' }
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

  describe '#browsing_histories' do
    let(:fc_user) { FactoryBot.build_stubbed(:fc_user, :activated) }
    let(:other_fc_user) { FactoryBot.build_stubbed(:fc_user, :activated) }
    let!(:project_a) { FactoryBot.create(:project, :with_impressions, impression_user: fc_user, created_at: 2.days.ago) }
    let!(:project_b) { FactoryBot.create(:project, :with_impressions, impression_user: fc_user, created_at: 1.day.ago) }
    let!(:project_c) { FactoryBot.create(:project, :with_impressions, impression_user: other_fc_user, created_at: 1.day.ago) }

    subject { fc_user.browsing_histories }

    it do
      is_expected.to eq [project_b, project_a]
    end
  end
end

# == Schema Information
#
# Table name: fc_users
#
#  id                            :bigint           not null, primary key
#  account_sfid                  :string
#  activated_at                  :datetime
#  activation_token              :string
#  confirmation_sent_at          :datetime
#  confirmation_token            :string
#  confirmed_at                  :datetime
#  contact_sfid                  :string
#  current_sign_in_at            :datetime
#  current_sign_in_ip            :inet
#  direct_otp                    :string
#  direct_otp_sent_at            :datetime
#  email                         :string           default(""), not null
#  encrypted_otp_secret_key      :string
#  encrypted_otp_secret_key_iv   :string
#  encrypted_otp_secret_key_salt :string
#  encrypted_password            :string           default(""), not null
#  failed_attempts               :integer          default(0), not null
#  last_sign_in_at               :datetime
#  last_sign_in_ip               :inet
#  lead_no                       :string
#  lead_sfid                     :string
#  locked_at                     :datetime
#  password_changed_at           :datetime
#  password_salt                 :string
#  profile_image                 :string
#  registration_completed_at     :datetime
#  remember_created_at           :datetime
#  reset_password_sent_at        :datetime
#  reset_password_token          :string
#  second_factor_attempts_count  :integer          default(0)
#  sign_in_count                 :integer          default(0), not null
#  totp_timestamp                :datetime
#  unconfirmed_email             :string
#  user_agent                    :string           default(""), not null
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  account_id                    :integer
#
# Indexes
#
#  index_fc_users_on_account_id                (account_id)
#  index_fc_users_on_account_sfid              (account_sfid)
#  index_fc_users_on_activation_token          (activation_token) UNIQUE
#  index_fc_users_on_confirmation_token        (confirmation_token) UNIQUE
#  index_fc_users_on_contact_sfid              (contact_sfid) UNIQUE
#  index_fc_users_on_email                     (email) UNIQUE
#  index_fc_users_on_encrypted_otp_secret_key  (encrypted_otp_secret_key) UNIQUE
#  index_fc_users_on_lead_no                   (lead_no) UNIQUE
#  index_fc_users_on_lead_sfid                 (lead_sfid)
#  index_fc_users_on_reset_password_token      (reset_password_token) UNIQUE
#
