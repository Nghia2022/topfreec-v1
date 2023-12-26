# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mypage::Fc::Phone::Confirmations', type: :request do
  subject do
    send_request
    response
  end

  let!(:fc_user) { FactoryBot.create(:fc_user, :activated) }
  let(:account) { FactoryBot.build_stubbed(:account) }
  let(:sf_account_fc) { FactoryBot.build(:sf_account_fc) }
  let(:sf_contact) { FactoryBot.build(:sf_contact) }

  before do
    sign_in(fc_user)
  end

  shared_context 'unconfirmed phone' do
    let(:unconfirmed_phone) { Faker::PhoneNumber.cell_phone.delete('-') }

    before do
      allow(fc_user).to receive(:account).and_return(account)
      allow(account).to receive(:to_sobject).and_return(sf_account_fc)
      allow(fc_user).to receive(:unconfirmed_phone).and_return(unconfirmed_phone)
    end
  end

  describe 'GET /mypage/fc/phone/confirmation' do
    include_context 'unconfirmed phone'

    it do
      is_expected.to have_http_status(:ok)
    end
  end

  describe 'POST /mypage/fc/phone/confirmation' do
    let!(:fc_user) { FactoryBot.create(:fc_user, :activated, direct_otp: code, direct_otp_sent_at: Time.current) }
    let(:code) { '123456' }
    let(:params) do
      {
        code:
      }
    end

    context 'when otp code is valid' do
      before do
        allow(fc_user.contact).to receive(:to_sobject).and_return(sf_contact)
        allow_any_instance_of(Restforce::Concerns::API).to receive(:update!).with('Contact', anything).and_return(true)
      end

      it do
        is_expected.to redirect_to(mypage_fc_settings_path)
      end
    end

    context 'when otp code is invalid' do
      include_context 'unconfirmed phone'

      let(:params) do
        {
          code: 'invalid'
        }
      end

      it do
        is_expected.to have_http_status(:ok)
      end
    end
  end

  describe 'PUT /mypage/fc/phone/confirmation/resend_code' do
    include_context 'unconfirmed phone'

    before do
      allow_any_instance_of(FcUser).to receive(:unconfirmed_phone).and_return(unconfirmed_phone)
    end

    it do
      is_expected.to redirect_to(mypage_fc_phone_confirmation_path)
    end

    it do
      aggregate_failures do
        stub = stub_request(:post, %r{https://api.twilio.com/2010-04-01/Accounts/AC.+/Messages\.json})
        expect do
          perform_enqueued_jobs do
            send_request
          end
          fc_user.reload
        end.to change(fc_user, :direct_otp).to(be_present)
          .and change(fc_user, :direct_otp_sent_at).to(be_present)

        expect(stub).to have_been_requested
      end
    end
  end
end
