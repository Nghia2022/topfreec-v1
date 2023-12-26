# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mypage::Fc::Dashboards', :erb, type: :request do
  subject do
    send_request
    response
  end

  let(:fc_user) { FactoryBot.create(:fc_user, :activated) }
  let(:sf_account_fc) { FactoryBot.build(:sf_account_fc) }
  let(:sf_contact) { FactoryBot.build(:sf_contact) }

  before do
    stub_salesforce_request
    allow_any_instance_of(Account).to receive(:to_sobject).and_return(sf_account_fc)
  end

  describe 'GET /mypage/fc' do
    shared_context 'with signed in as fc_user' do
      before do
        sign_in(fc_user)
      end
    end

    describe 'when user is fc_user' do
      include_context 'with signed in as fc_user'

      it do
        is_expected.to have_http_status(:ok)
      end
    end

    describe 'botchan' do
      include_context 'with signed in as fc_user'

      it do
        send_request
        expect(response.body)
          .to have_selector(:testid, 'fc/dashboard')
          .and not_include('botchan')
      end
    end

    describe 'update tracked fields' do
      include_context 'with signed in as fc_user'

      let(:contact) { fc_user.contact }
      let(:now) { '2020-10-01 23:59:00'.in_time_zone }
      let(:tomorrow) { '2020-10-02 00:0:00'.in_time_zone }

      around do |ex|
        travel_to(now) { ex.run }
      end

      it do
        get mypage_fc_root_path
        travel_to(tomorrow)
        expect do
          send_request
        end.to change { contact.reload.fcweb_logindatetime__c }.from(now).to(tomorrow)
      end
    end

    context 'when user is fc company' do
      include_context 'with signed in as fc_user'

      let(:fc_user) { FactoryBot.create(:fc_user, :fc_company) }

      it do
        is_expected.to redirect_to(mypage_fc_directions_path)
      end
    end

    context 'when user is fc company' do
      include_context 'with signed in as fc_user'

      let(:fc_user) { FactoryBot.create(:client_user) }

      it do
        is_expected.to redirect_to(new_fc_user_session_path)
      end
    end

    context 'when user is not signed in' do
      let(:fc_user) { nil }

      it do
        is_expected.to redirect_to(new_fc_user_session_path)
      end
    end

    context 'when user is not allowed to sign in' do
      include_context 'with signed in as fc_user'

      before do
        allow_any_instance_of(Contact).to receive(:sign_in_allowed_fc?).and_return(false)
      end

      it do
        is_expected.to redirect_to(new_fc_user_session_path)
      end
    end
  end
end
