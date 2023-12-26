# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Activations', type: :request do
  subject do
    send_request
    response
  end

  before do
    inject_session(oauth_email: 'test@ruffnote.com')
  end

  describe 'GET /fcweb-admin-01/activations' do
    it do
      is_expected.to have_http_status(:ok)
    end
  end

  describe 'PUT /fcweb-admin-01/activations/:id' do
    let(:id) { fc_user.id }
    let(:lead_no) { '1234567' }
    let!(:fc_user) { FactoryBot.create(:fc_user, lead_no:) }
    let!(:contact) { FactoryBot.create(:contact, :fc) }
    let(:contact_sfid) { contact.sfid }
    let(:sf_account) { FactoryBot.build_stubbed(:sf_account_fc) }

    context 'with valid params' do
      let(:params) do
        {
          fc_user: {
            lead_no:,
            contact_sfid:
          }
        }
      end

      it do
        is_expected.to redirect_to(admin_activations_path)
      end

      it do
        expect do
          send_request
          fc_user.reload
          contact.reload
        end.to change(fc_user, :contact_sfid).from(nil).to(contact_sfid)
          .and change(fc_user, :contact).from(nil).to(contact)
          .and change(contact, :existsinheroku__c).from(false).to(true)
      end

      describe 'send activation instructions' do
        before do
          allow(Salesforce::Account).to receive(:find).and_return(sf_account)
        end

        it do
          expect do
            perform_enqueued_jobs do
              send_request
            end
          end.to change(FcUserMailer.deliveries, :count).by(1)
        end
      end
    end

    context 'with invalid params' do
      let(:params) do
        {
          fc_user: {
            lead_no:
          }
        }
      end

      it do
        is_expected.to have_http_status(:ok)
      end

      it do
        send_request
        expect(response.body).to have_content('正しく入力されていない項目があります。')
      end
    end
  end
end
