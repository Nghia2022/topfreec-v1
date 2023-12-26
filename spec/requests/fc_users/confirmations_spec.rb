# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'FcUsers::Confirmations', type: :request do
  subject do
    send_request
    response
  end

  describe 'GET /confirmation' do
    let!(:fc_user) { FactoryBot.create(:fc_user, email: current_email, unconfirmed_email: new_email, confirmation_token:, contact_sfid: sf_contact.sfid) }
    let(:sf_contact) { FactoryBot.build_stubbed(:sf_contact) }
    let(:confirmation_token) { Devise.friendly_token }
    let(:current_email) { Faker::Internet.email }
    let(:new_email) { Faker::Internet.email }
    let(:params) do
      {
        confirmation_token:
      }
    end

    context 'when update email successfully' do
      before do
        expect_any_instance_of(Restforce::Concerns::API).to receive(:update!).with('Contact', Id: sf_contact.sfid, Web_LoginEmail__c: new_email).and_return(true)
      end

      it do
        is_expected.to redirect_to(new_fc_user_session_path)
      end
    end

    context 'when failed to update email in salesforce' do
      before do
        allow_any_instance_of(Restforce::Concerns::API).to receive(:update!).with('Contact', Id: sf_contact.sfid, Web_LoginEmail__c: new_email).and_raise(Restforce::ResponseError, 'error')
      end

      it do
        expect do
          subject
          fc_user.reload
        end.to raise_error(StandardError)
          .and not_change(fc_user, :email).from(current_email)
          .and not_change(fc_user, :unconfirmed_email).from(new_email)
      end
    end
  end
end
