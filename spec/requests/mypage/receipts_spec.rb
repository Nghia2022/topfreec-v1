# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mypage::Receipts', type: :request do
  subject do
    send_request
    response
  end

  let(:fc_user) { FactoryBot.create(:fc_user, :activated) }
  let(:sf_account_fc) { FactoryBot.build(:sf_account_fc) }
  let(:receipt) { FactoryBot.create(:receipt, :with_notification, receiver: fc_user, notification_trait:) }
  let(:notification_trait) { [{ link: }] }
  let(:link) { 'https://example.com/' }

  before do
    stub_salesforce_request
    allow_any_instance_of(Account).to receive(:to_sobject).and_return(sf_account_fc)
  end

  describe 'PATCH /mypage/receipts/:id' do
    let(:id) { receipt.id }

    before do
      sign_in(fc_user)
    end

    it do
      is_expected.to have_http_status(:no_content)
    end

    it do
      expect do
        send_request
      end.to change { receipt.reload.is_read? }.from(false).to(true)
    end
  end
end
