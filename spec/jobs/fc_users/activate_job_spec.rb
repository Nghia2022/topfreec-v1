# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FcUsers::ActivateJob, type: :job do
  subject(:job) { described_class.new }

  let(:lead_no) { '12345' }
  let(:contact_sfid) { FactoryBot.generate(:sfid) }

  shared_context 'with existing fc_user' do
    let!(:fc_user) { FactoryBot.create(:fc_user, :unconfirmed, lead_no:) }
  end

  describe '#perform' do
    subject { job.perform(lead_no, contact_sfid) }

    context 'when synced contact and account' do
      include_context 'with existing fc_user'

      let!(:account) { FactoryBot.create(:account_fc) }
      named_let!(:contact) { FactoryBot.create(:contact, :fc, account:, sfid: contact_sfid) }

      it do
        expect do
          subject
          fc_user.reload
        end.to change(fc_user, :contact_sfid).from(nil).to(contact_sfid)
          .and change(fc_user, :contact).from(nil).to(contact)
          .and change(fc_user, :activation_token).from(nil).to(be_present)
          .and not_change(fc_user, :confirmed_at).from(nil)
      end
    end

    context 'when not synced contact' do
      include_context 'with existing fc_user'

      let!(:account) { FactoryBot.create(:account_fc) }

      it do
        expect do
          subject
          fc_user.reload
        end.to raise_error(Fc::UserActivation::ContactNotFound)
          .and not_change(fc_user, :contact_sfid).from(nil)
      end
    end

    context 'when fc_user not exists' do
      let!(:account) { FactoryBot.create(:account_fc) }
      named_let!(:contact) { FactoryBot.create(:contact, :fc, account:, sfid: contact_sfid) }

      it do
        expect do
          subject
        end.to change(FcUser, :count).by(1)
      end

      it do
        subject
        expect(FcUser.last).to have_attributes(
          email:            contact.web_loginemail__c,
          activation_token: be_present,
          confirmed_at:     nil,
          contact:
        )
      end
    end
  end

  describe '.perform_later' do
    subject { described_class.perform_later(lead_no, contact_sfid) }

    context 'when not synced contact' do
      include_context 'with existing fc_user'

      let!(:account) { FactoryBot.create(:account_fc) }
      named_let!(:contact) { FactoryBot.create(:contact, :fc, account:, sfid: contact_sfid) }
      let(:sf_account) { FactoryBot.build_stubbed(:sf_account_fc) }

      before do
        allow(Contact).to receive(:find_by).with(sfid: contact_sfid).and_return(nil)
        allow(Salesforce::Account).to receive(:find).and_return(sf_account)
      end

      it do
        perform_enqueued_jobs do
          expect do
            subject
            fc_user.reload
          end.to raise_error(Fc::UserActivation::RetryStopped)
            .and not_change(fc_user, :contact_sfid).from(nil)
        end
      end
    end

    context 'when contact is unsynced first time, and synced second time' do
      include_context 'with existing fc_user'

      let!(:account) { FactoryBot.create(:account_fc) }
      named_let!(:contact) { FactoryBot.create(:contact, :fc, account:, sfid: contact_sfid) }
      let(:sf_account) { FactoryBot.build_stubbed(:sf_account_fc) }

      before do
        allow(Contact).to receive(:find_by).with(sfid: contact_sfid).and_return(nil, contact)
        allow(Salesforce::Account).to receive(:find).and_return(sf_account)
      end

      it do
        expect do
          perform_enqueued_jobs do
            subject
          end
          fc_user.reload
        end.to change(fc_user, :contact_sfid).from(nil).to(contact_sfid)
      end
    end

    context 'when fc_user not exists' do
      let!(:account) { FactoryBot.create(:account_fc) }
      named_let!(:contact) { FactoryBot.create(:contact, :fc, account:, sfid: contact_sfid) }
      let(:sf_account) { FactoryBot.build_stubbed(:sf_account_fc) }

      before do
        allow(Salesforce::Account).to receive(:find).and_return(sf_account)
      end

      it do
        expect do
          perform_enqueued_jobs do
            subject
          end
        end.to change(FcUser, :count).by(1)
      end

      it do
        perform_enqueued_jobs do
          subject
        end

        expect(FcUser.last).to have_attributes(
          email:            contact.web_loginemail__c,
          activation_token: be_present,
          confirmed_at:     nil,
          contact:
        )
      end
    end
  end
end
