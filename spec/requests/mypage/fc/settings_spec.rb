# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mypage::Fc::Settings', :erb, type: :request do
  subject do
    send_request
    response
  end

  let(:fc_user) { FactoryBot.create(:fc_user, :activated) }
  let(:sf_account_fc) { FactoryBot.build(:sf_account_fc) }
  let(:sf_contact) { FactoryBot.build(:sf_contact) }
  let(:sf_content_document) { FactoryBot.build(:sf_content_document) }

  before do
    allow_any_instance_of(Account).to receive(:to_sobject).and_return(sf_account_fc)
    allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
    allow(Salesforce::ContentDocument).to receive(:find_by).and_return(sf_content_document)
  end

  describe 'GET /mypage/fc/settings' do
    before do
      sign_in(fc_user)
    end

    it do
      is_expected.to have_http_status(:ok)
    end
  end
end
