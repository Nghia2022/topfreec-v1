# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DirectionStatusCheckJob, type: :job do
  let(:fc_user) { FactoryBot.create(:fc_user, :activated) }
  let(:main_fc_contact) { fc_user.contact }
  let(:client_account) { FactoryBot.create(:account_client) }
  let(:main_cl_contact) { FactoryBot.create(:contact, account: client_account) }
  let(:sub_cl_contact) { nil }
  let(:project) { FactoryBot.create(:project, client: client_account, main_fc_contact:, main_cl_contact:, sub_cl_contact:) }

  describe '#perform' do
    let(:job) { DirectionStatusCheckJob.new }
    let(:sf_main_cl_contact) { FactoryBot.build_stubbed(:sf_contact) }
    let(:sf_sub_cl_contact) { FactoryBot.build_stubbed(:sf_contact) }
    let(:sf_main_fc_contact) { FactoryBot.build_stubbed(:sf_contact) }
    let(:sf_sub_fc_contact) { FactoryBot.build_stubbed(:sf_contact) }
    let(:sf_account) { FactoryBot.build_stubbed(:sf_account_fc) }
    let(:main_mws_user) { FactoryBot.build_stubbed(:sf_user) }
    let(:sub_mws_user) { FactoryBot.build_stubbed(:sf_user) }

    let(:client_presenter_builder) do
      Client::ManageDirection::DirectionMailerPresenterBuilder.new(direction).tap do |builder|
        allow(builder).to receive(:main_cl_contact).and_return(sf_main_cl_contact)
        allow(builder).to receive(:sub_cl_contact).and_return(sf_sub_cl_contact)
        allow(builder).to receive(:fc_account).and_return(sf_account)
        allow(builder).to receive(:main_mws_user).and_return(main_mws_user)
        allow(builder).to receive(:sub_mws_user).and_return(sub_mws_user)
      end
    end
    let(:fc_presenter_builder) do
      Fc::ManageDirection::DirectionMailerPresenterBuilder.new(direction).tap do |builder|
        allow(builder).to receive(:main_fc_contact).and_return(sf_main_fc_contact)
        allow(builder).to receive(:sub_fc_contact).and_return(sf_sub_fc_contact)
        allow(builder).to receive(:fc_account).and_return(sf_account)
        allow(builder).to receive(:main_mws_user).and_return(main_mws_user)
        allow(builder).to receive(:sub_mws_user).and_return(sub_mws_user)
      end
    end

    before do
      stub_salesforce_create_request('Task', anything)
      allow(Client::ManageDirection::DirectionMailerPresenterBuilder).to receive(:new).and_return(client_presenter_builder)
      allow(Fc::ManageDirection::DirectionMailerPresenterBuilder).to receive(:new).and_return(fc_presenter_builder)
      allow(Tasks::RequestConfirmationToClientTask).to receive(:sf_contact).and_return(ProfileDecorator.decorate(sf_main_cl_contact))
    end

    shared_examples 'start direction' do
      describe 'send email to client' do
        it do
          expect do
            perform_enqueued_jobs do
              job.perform
            end
          end.to change(DirectionMailer.deliveries, :count).by(1)
        end

        it do
          perform_enqueued_jobs do
            job.perform
          end

          email = open_email(sf_main_cl_contact.Web_LoginEmail__c)
          expect(email).to deliver_to(sf_main_cl_contact.Web_LoginEmail__c)
        end

        context 'with sub cl' do
          let(:sub_cl_contact) { FactoryBot.create(:contact) }

          it do
            perform_enqueued_jobs do
              job.perform
            end

            email = open_email(sf_main_cl_contact.Web_LoginEmail__c)
            expect(email).to deliver_to(sf_main_cl_contact.Web_LoginEmail__c)
          end
        end
      end

      describe 'clear DirectionEvent' do
        it do
          expect do
            job.perform
          end.to change(DirectionEvent, :count).from(1).to(0)
        end
      end
    end

    shared_examples 'not start direction' do
      describe 'not send email to client' do
        it do
          expect do
            perform_enqueued_jobs do
              job.perform
            end
          end.to change(DirectionMailer.deliveries, :count).by(0)
        end
      end

      describe 'clear DirectionEvent' do
        it do
          expect do
            job.perform
          end.to change(DirectionEvent, :count).from(1).to(0)
        end
      end
    end

    describe 'start direction' do
      let!(:direction) do
        FactoryBot.create(:direction, direction_trait, project:).tap do
          DirectionEvent.delete_all
        end
      end
      let!(:direction_event) { FactoryBot.create(:direction_event, direction:, old_hc_lastop: nil, new_hc_lastop: 'SYNCED', old_status:, new_status:, mail_queued:) }
      let(:old_status) { nil }
      let(:new_status) { :in_prepare }
      let(:mail_queued) { false }
      let(:direction_trait) { :in_prepare }

      context 'when direction is in_prepare and mail queued' do
        let(:mail_queued) { true }
        it_behaves_like 'start direction'
      end

      context 'when direction is in_prepare and not mail queued' do
        let(:mail_queued) { false }

        it_behaves_like 'not start direction'
      end

      context 'when direction is rejected by client and mail queued' do
        let!(:direction_event) { FactoryBot.create(:direction_event, :synced, direction:, old_status:, new_status:, mail_queued:) }
        let(:old_status) { :rejected }
        let(:new_status) { :rejected }
        let(:mail_queued) { true }
        let(:direction_trait) { :rejected_by_client }

        it_behaves_like 'start direction'
      end

      context 'when direction is rejected by client and mail not queued' do
        let!(:direction_event) { FactoryBot.create(:direction_event, :synced, direction:, old_status:, new_status:, mail_queued:) }
        let(:old_status) { :rejected }
        let(:new_status) { :rejected }
        let(:mail_queued) { false }
        let(:direction_trait) { :rejected_by_client }

        it_behaves_like 'not start direction'
      end

      context 'when direction is rejected by fc and mail queued' do
        let!(:direction_event) { FactoryBot.create(:direction_event, :synced, direction:, old_status:, new_status:, mail_queued:) }
        let(:old_status) { :rejected }
        let(:new_status) { :rejected }
        let(:mail_queued) { true }
        let(:direction_trait) { :rejected_by_fc }

        it_behaves_like 'start direction'
      end

      context 'when direction is rejected by fc and mail not queued' do
        let!(:direction_event) { FactoryBot.create(:direction_event, :synced, direction:, old_status:, new_status:, mail_queued:) }
        let(:old_status) { :rejected }
        let(:new_status) { :rejected }
        let(:mail_queued) { false }
        let(:direction_trait) { :rejected_by_fc }

        it_behaves_like 'not start direction'
      end
    end

    describe 'finalize direction' do
      let(:direction) { FactoryBot.create(:direction, :completed, project:) }

      context 'when status transition from :waiting_for_fc to :completed in salesforce' do
        let!(:direction_event) { FactoryBot.create(:direction_event, direction:, old_hc_lastop: 'SYNCED', new_hc_lastop: 'SYNCED', old_status: :waiting_for_fc, new_status: :completed) }

        it do
          expect do
            perform_enqueued_jobs do
              job.perform
            end
          end.to change(Notification, :count).by(1)
            .and change(Receipt, :count).by(1)
        end
      end

      context 'when status transition from :waiting_for_fc to :completed in heroku' do
        let!(:direction_event) { FactoryBot.create(:direction_event, direction:, old_hc_lastop: 'UPDATED', new_hc_lastop: 'SYNCED', old_status: :waiting_for_fc, new_status: :completed) }

        it do
          expect do
            perform_enqueued_jobs do
              job.perform
            end
          end.to not_change(Notification, :count)
            .and not_change(Receipt, :count)
        end
      end
    end
  end
end
