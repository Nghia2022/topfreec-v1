# frozen_string_literal: true

require 'rails_helper'

RSpec.xdescribe 'FcUsers::TwoFactorAuthentications', :erb, type: :request do
  subject do
    send_request
    response
  end

  let(:sf_account_fc) { FactoryBot.build(:sf_account_fc) }

  describe 'GET /two_factor_authentication' do
    let(:user) { FactoryBot.create(:fc_user, :activated) }
    let(:sf_contact) { FactoryBot.build(:sf_contact, :fc, Phone: '01234567890') }

    before do
      stub_salesforce_request
      allow_any_instance_of(Account).to receive(:to_sobject).and_return(sf_account_fc)
      allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
      sign_in(user)
    end

    it do
      is_expected.to have_http_status(:ok)
    end
  end

  describe 'GET /two_factor_authentication/resend_code' do
    let(:user) { FactoryBot.create(:fc_user, :activated, direct_otp: code, direct_otp_sent_at: Time.current) }
    let(:sf_contact) { FactoryBot.build(:sf_contact, :fc, Phone: '09012345678') }
    let(:code) { '123456' }

    before do
      allow_any_instance_of(Account).to receive(:to_sobject).and_return(sf_account_fc)
      allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
      sign_in(user)
    end

    it do
      is_expected.to have_http_status(:found)
      .and redirect_to fc_user_two_factor_authentication_path
    end
    it do
      send_request
      expect(flash).to have_attributes(notice: '認証コードを再送信しました')
    end
  end

  describe 'PUT /two_factor_authentication' do
    let(:user) { FactoryBot.create(:fc_user, :activated, direct_otp: code, direct_otp_sent_at: Time.current) }
    let(:sf_contact) { FactoryBot.build(:sf_contact, :fc, Phone: '01234567890') }
    let(:code) { '123456' }

    before do
      stub_salesforce_request
      allow_any_instance_of(Account).to receive(:to_sobject).and_return(sf_account_fc)
      allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
      sign_in(user)
    end

    context 'valid OTP code' do
      let(:params) do
        {
          code:
        }
      end

      it do
        is_expected.to have_http_status(:found)
      end

      describe 'remember_tfa cookie' do
        it do
          send_request
          expect(response.cookies['remember_tfa']).to be_present
        end
      end
    end

    context 'invalid OTP code' do
      let(:params) do
        {
          code: '000000'
        }
      end

      it { is_expected.to have_http_status(:ok) }
      it do
        send_request
        expect(flash).to have_attributes(alert: '認証コードが間違っています')
      end

      describe 'remember_tfa cookie' do
        it do
          send_request
          expect(response.cookies['remember_tfa']).to be_blank
        end
      end
    end
  end
end
