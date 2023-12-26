# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mypage::Fc::Profiles', :erb, type: :request do
  subject do
    send_request
    response
  end

  let(:fc_user) { FactoryBot.create(:fc_user, :activated) }
  let(:sf_account_fc) { FactoryBot.build(:sf_account_fc) }
  let(:sf_contact) { FactoryBot.build(:sf_contact) }
  let(:education) { FactoryBot.build_stubbed(:education) }

  before do
    stub_salesforce_request
    allow_any_instance_of(Account).to receive(:to_sobject).and_return(sf_account_fc)
    allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
    allow(Education).to receive(:for_contact).and_return([education])
  end

  describe 'GET /mypage/fc/profile' do
    before do
      sign_in(fc_user)
    end

    it do
      is_expected.to redirect_to(:mypage_fc_settings)
    end
  end
end
