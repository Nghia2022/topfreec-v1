# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mypage::Fc::Settings::MlRejects', :erb, type: :request do
  subject(:perform) do
    send_request
    response
  end

  let(:fc_user) { FactoryBot.create(:fc_user, :activated, contact:) }
  let(:account) { fc_user.account }

  before do
    allow_any_instance_of(Account).to receive(:to_sobject).and_return(account)
    sign_in(fc_user)
  end

  shared_examples 'failed to update ml setting' do
    before do
      allow_any_instance_of(Contact).to receive(:update).and_return(false)
    end

    it do
      is_expected.to have_http_status(:unprocessable_entity)
    end

    it do
      expect do
        perform
        contact.reload
      end.to not_change(contact, :ml_reject__c?)
    end
  end

  describe 'GET /mypage/fc/settings/ml_reject/edit' do
    context 'when ml_reject is true' do
      let(:contact) { FactoryBot.create(:contact, :fc, ml_reject__c: true) }

      it do
        expect(perform.body).to have_content('開始')
          .and have_selector(:testid, 'mypage/fc/settings/ml_rejects')
      end
    end

    context 'when ml_reject is false' do
      let(:contact) { FactoryBot.create(:contact, :fc, ml_reject__c: false) }

      it do
        expect(perform.body).to have_content('停止')
          .and have_selector(:testid, 'mypage/fc/settings/ml_rejects')
      end
    end
  end

  describe 'PATCH /mypage/fc/settings/ml_reject' do
    let(:contact) { FactoryBot.create(:contact, :fc, ml_reject__c: true) }

    it do
      expect do
        perform
      end.to change { contact.reload.ml_reject__c? }.from(true).to(false)
    end

    it_behaves_like 'failed to update ml setting'
  end

  describe 'DELETE /mypage/fc/settings/ml_reject' do
    let(:contact) { FactoryBot.create(:contact, :fc, ml_reject__c: false) }

    it do
      expect do
        perform
      end.to change { contact.reload.ml_reject__c? }.from(false).to(true)
    end

    it_behaves_like 'failed to update ml setting'
  end
end
