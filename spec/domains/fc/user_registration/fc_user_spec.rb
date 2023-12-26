# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Fc::UserRegistration::FcUser, type: :model do
  describe 'validations' do
    it do
      is_expected.to validate_presence_of(:last_name).with_message('姓を入力してください')
    end

    it do
      is_expected.to validate_presence_of(:first_name).with_message('名を入力してください')
    end

    it do
      is_expected.to validate_presence_of(:last_name_kana).with_message('姓カナを入力してください')
    end

    it do
      is_expected.to validate_presence_of(:first_name_kana).with_message('名カナを入力してください')
    end

    describe '#phone' do
      it do
        is_expected.to validate_presence_of(:phone).with_message('携帯番号を入力してください')
      end

      describe 'format' do
        it do
          is_expected.to not_allow_values('', 'a', '123').for(:phone).with_message('携帯番号は不正な値です')
        end
      end
    end

    it do
      is_expected.to validate_presence_of(:work_location1)
    end
  end

  describe '#create_lead_in_salesforce' do
    let(:attributes) do
      last_name = Faker::Japanese::Name.last_name
      first_name = Faker::Japanese::Name.first_name

      FactoryBot.attributes_for(:fc_user).merge(
        last_name:,
        first_name:,
        last_name_kana:  last_name.yomi,
        first_name_kana: first_name.yomi,
        phone:           Faker::PhoneNumber.phone_number.delete('-'),
        work_location1:  Fc::UserRegistration::FcUser.work_location1.values.sample,
        session_id:      SecureRandom.hex
      )
    end

    let(:lead_sfid) { SecureRandom.uuid }
    let(:lead_no) { '1234567' }
    let(:lead_sobject) do
      Restforce::SObject.new(
        Type:      'Lead',
        Id:        lead_sfid,
        Email:     attributes[:email],
        LeadId__c: lead_no
      )
    end

    before do
      allow(Salesforce::Lead).to receive(:find_or_create_by).and_return(lead_sobject)
    end

    context 'sent from PC' do
      let(:user_agent) { 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Safari/537.36' }

      it 'sets `lead_sfid` before create' do
        fc_user = Fc::UserRegistration::FcUser.new(attributes)
        fc_user.confirming = '1'
        fc_user.save
        expect(Salesforce::Lead).to have_received(:find_or_create_by).with(
          {
            LastName:                        attributes[:last_name],
            firstName:                       attributes[:first_name],
            Kana_Sei__c:                     attributes[:last_name_kana],
            Kana_Mei__c:                     attributes[:first_name_kana],
            Email:                           attributes[:email],
            Phone:                           attributes[:phone],
            WorkLocation__c:                 fc_user.send(:work_location__c),
            lp_code__c:                      Fc::UserRegistration::FcUser::LP_CODE,
            Career_Declaration_Confirmed__c: true,
            Agreement1__c:                   true,
            Agreement3__c:                   true,
            AD_EBiS_member_name__c:          attributes[:session_id],
            LeadSource:                      'Web',
            user_agent__c:                   'PC'
          }
        )
        expect(fc_user.lead_sfid).to eq(lead_sfid)
        expect(fc_user.lead_no).to eq(lead_no)
      end
    end

    context 'sent from SP' do
      let(:user_agent) { 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/111.0.5563.72 Mobile/15E148 Safari/604.1' }

      it 'sets `lead_sfid` before create' do
        fc_user = Fc::UserRegistration::FcUser.new(attributes.merge(user_agent:))
        fc_user.confirming = '1'
        fc_user.save
        expect(Salesforce::Lead).to have_received(:find_or_create_by).with(
          {
            LastName:                        attributes[:last_name],
            firstName:                       attributes[:first_name],
            Kana_Sei__c:                     attributes[:last_name_kana],
            Kana_Mei__c:                     attributes[:first_name_kana],
            Email:                           attributes[:email],
            Phone:                           attributes[:phone],
            WorkLocation__c:                 fc_user.send(:work_location__c),
            lp_code__c:                      Fc::UserRegistration::FcUser::LP_CODE,
            Career_Declaration_Confirmed__c: true,
            Agreement1__c:                   true,
            Agreement3__c:                   true,
            AD_EBiS_member_name__c:          attributes[:session_id],
            LeadSource:                      'Web',
            user_agent__c:                   'SP'
          }
        )
        expect(fc_user.lead_sfid).to eq(lead_sfid)
        expect(fc_user.lead_no).to eq(lead_no)
      end
    end
  end
end

# == Schema Information
#
# Table name: users
#
#  id                            :bigint           not null, primary key
#  confirmation_sent_at          :datetime
#  confirmation_token            :string
#  confirmed_at                  :datetime
#  current_sign_in_at            :datetime
#  current_sign_in_ip            :inet
#  direct_otp                    :string
#  direct_otp_sent_at            :datetime
#  email                         :string           default(""), not null
#  encrypted_otp_secret_key      :string
#  encrypted_otp_secret_key_iv   :string
#  encrypted_otp_secret_key_salt :string
#  encrypted_password            :string           default(""), not null
#  last_sign_in_at               :datetime
#  last_sign_in_ip               :inet
#  lead_sfid                     :string
#  remember_created_at           :datetime
#  reset_password_sent_at        :datetime
#  reset_password_token          :string
#  second_factor_attempts_count  :integer          default(0)
#  sign_in_count                 :integer          default(0), not null
#  totp_timestamp                :datetime
#  unconfirmed_email             :string
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  account_id                    :integer
#
# Indexes
#
#  index_users_on_account_id                (account_id)
#  index_users_on_confirmation_token        (confirmation_token) UNIQUE
#  index_users_on_email                     (email) UNIQUE
#  index_users_on_encrypted_otp_secret_key  (encrypted_otp_secret_key) UNIQUE
#  index_users_on_lead_sfid                 (lead_sfid)
#  index_users_on_reset_password_token      (reset_password_token) UNIQUE
#
