# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mypage::Client::Dashboards', :erb, type: :request do
  subject do
    send_request
    response
  end

  let(:client_user) { FactoryBot.create(:client_user, :with_contact) }

  describe 'GET /mypage/cl' do
    let(:contact) { client_user.contact }
    let(:now) { '2020-10-01 23:59:00'.in_time_zone }
    let(:tomorrow) { '2020-10-02 00:00:00'.in_time_zone }

    around do |ex|
      travel_to(now) { ex.run }
    end

    before do
      sign_in(client_user)
    end

    it do
      is_expected.to have_http_status(:found)
        .and redirect_to mypage_client_directions_path
    end

    it do
      get mypage_client_root_path
      travel_to(tomorrow)
      expect do
        send_request
      end.to change { contact.reload.fcweb_logindatetime__c }.from(now).to(tomorrow)
    end
  end
end
