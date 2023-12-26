# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mypage::Fc::Histories', type: :request do
  subject do
    send_request
    response
  end

  let(:fc_user) { FactoryBot.create(:fc_user, :activated) }
  let(:sf_account_fc) { FactoryBot.build(:sf_account_fc) }

  before do
    stub_salesforce_request
    allow_any_instance_of(Account).to receive(:to_sobject).and_return(sf_account_fc)
  end

  describe 'GET /mypage/fc/histories' do
    before do
      sign_in(fc_user)
    end

    it do
      is_expected.to have_http_status(:ok)
    end
  end
end
