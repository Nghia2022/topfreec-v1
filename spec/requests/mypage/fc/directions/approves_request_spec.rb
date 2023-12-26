# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mypage::Fc::Directions::Approves', type: :request do
  subject do
    send_request
    response
  end

  let!(:fc_user) { FactoryBot.create(:fc_user, :activated) }
  let(:account) { fc_user.account }
  let(:contact) { fc_user.contact }
  let(:sf_account_fc) { FactoryBot.build(:sf_account_fc) }
  let(:sf_contact) { FactoryBot.build(:sf_contact) }
  let(:main_mws_user) { FactoryBot.build_stubbed(:sf_user) }
  let(:sub_mws_user) { FactoryBot.build_stubbed(:sf_user) }

  describe 'GET /mypage/fc/directions/:id/approve' do
    let(:id) { direction.id }
    let(:project) { FactoryBot.create(:project, :with_client, fc_account: account, main_fc_contact: contact) }
    let!(:direction) { FactoryBot.create(:direction, :waiting_for_fc, project:) }

    before do
      sign_in(fc_user)
    end

    it { is_expected.to have_http_status(:ok) }
  end

  describe 'POST /mypage/fc/directions/:id/approve' do
    let(:id) { direction.id }
    let(:project) { FactoryBot.create(:project, :with_client, fc_account: account, main_fc_contact: contact) }
    let!(:direction) { FactoryBot.create(:direction, :waiting_for_fc, project:, directionmonth__c: '2020年10月') }

    let(:fc_presenter_builder) do
      Fc::ManageDirection::DirectionMailerPresenterBuilder.new(direction).tap do |builder|
        allow(builder).to receive(:main_fc_contact).and_return(sf_contact)
        allow(builder).to receive(:sub_fc_contact).and_return(Salesforce::Contact.null)
        allow(builder).to receive(:fc_account).and_return(sf_account_fc)
        allow(builder).to receive(:main_mws_user).and_return(main_mws_user)
        allow(builder).to receive(:sub_mws_user).and_return(sub_mws_user)
      end
    end

    before do
      stub_salesforce_create_request('Task', anything)
      allow(fc_user.contact).to receive(:to_sobject).and_return(sf_contact)
      allow(Fc::ManageDirection::DirectionMailerPresenterBuilder).to receive(:new).and_return(fc_presenter_builder)

      sign_in(fc_user)
    end

    context 'when valid' do
      it do
        is_expected.to redirect_to(mypage_fc_directions_path)
      end

      it do
        expect do
          send_request
          direction.reload
        end.to change(direction, :isapprovedbyfc__c?).from(false).to(true)
      end

      it do
        expect do
          perform_enqueued_jobs do
            send_request
          end
        end.to change { DirectionMailer.deliveries.count }.by(1)
      end
    end

    context 'when request failed' do
      context 'when restforce raise error' do
        before do
          allow_any_instance_of(Tasks::CreateService).to receive(:call).and_raise(Restforce::ResponseError, 'error')
        end

        it do
          expect do
            send_request
            direction.reload
          end.to raise_error(StandardError)
            .and not_change(direction, :status__c)
            .and not_change(direction, :isapprovedbyfc__c)
            .and not_change(direction, :approveroffc__c)
        end
      end

      context 'when direction not saved' do
        before do
          allow_any_instance_of(Direction).to receive(:save).and_return(false)
        end

        it do
          is_expected.to redirect_to(mypage_fc_directions_path)
        end

        it do
          send_request
          expect(flash).to have_attributes(alert: '業務指示を確認できませんでした')
        end

        it do
          expect do
            send_request
            direction.reload
          end.to not_change(direction, :status__c)
            .and not_change(direction, :isapprovedbyfc__c)
            .and not_change(direction, :approveroffc__c)
        end
      end
    end
  end
end
