# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::FcUsers', type: :request do
  subject do
    send_request
    response
  end

  describe 'PUT /api/v1/fc_users/:contact_sfid/activate' do
    let(:lead_no) { '1234567' }
    let!(:fc_user) { FactoryBot.create(:fc_user, lead_no:) }
    let!(:contact) { FactoryBot.create(:contact, :fc) }
    let(:contact_sfid) { contact.sfid }
    let(:sf_account) { FactoryBot.build_stubbed(:sf_account_fc) }
    let(:params) do
      {
        lead_no:,
        contact_sfid:
      }
    end

    around do |example|
      ActionController::Base.allow_forgery_protection = true
      example.run
      ActionController::Base.allow_forgery_protection = false
    end

    context 'when valid' do
      before do
        allow(Salesforce::Account).to receive(:find).and_return(sf_account)
      end

      it '', :show_in_doc do
        is_expected.to have_http_status(:accepted)
      end

      it do
        expect do
          perform_enqueued_jobs do
            send_request
          end
          fc_user.reload
          contact.reload
        end.to change(fc_user, :contact_sfid).from(nil).to(contact_sfid)
          .and change(fc_user, :contact).from(nil).to(contact)
          .and change(contact, :existsinheroku__c).to(true)
      end

      context 'when fc_user does not exist' do
        let!(:fc_user) { nil }

        it do
          expect do
            perform_enqueued_jobs do
              send_request
            end
            contact.reload
          end.to change(contact, :existsinheroku__c).to(true)
        end

        it do
          perform_enqueued_jobs do
            send_request
          end
          expect(FcUser.last).to have_attributes(
            email:        contact.web_loginemail__c,
            contact_sfid:
          )
        end
      end

      describe 'send activation instructions' do
        it do
          expect do
            perform_enqueued_jobs do
              send_request
            end
          end.to change(FcUserMailer.deliveries, :count).by(1)
        end
      end

      context 'when called twice at the same time' do
        let(:activation_fc_user) { ActiveType.cast(fc_user, Fc::UserActivation::FcUser) }

        before do
          allow(Fc::UserActivation::FcUser).to receive(:find_by).and_return(activation_fc_user)
          allow(activation_fc_user).to receive(:send_activation)
        end

        it 'email is sent only once', retry: 3 do
          expect do
            Parallel.each(2.times, in_threads: 2) do
              ActiveRecord::Base.connection_pool.with_connection do
                perform_enqueued_jobs do
                  put activate_api_v1_fc_user_path(contact_sfid:), params:
                end
              end
            end
          end.to change(FcUserMailer.deliveries, :count).by(1)
        end
      end
    end

    context 'when already activated' do
      let!(:fc_user) { FactoryBot.create(:fc_user, :activated, contact_sfid:, lead_no:) }

      it do
        is_expected.to have_http_status(:unprocessable_entity)
      end

      it do
        send_request
        expect(response_json.dig('messages', 'base')).to match [I18n.t('activerecord.errors.models.fc_user.attributes.base.already_activated')]
      end
    end
  end
end
