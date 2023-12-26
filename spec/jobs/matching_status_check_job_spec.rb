# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MatchingStatusCheckJob, type: :job do
  let(:matching) do
    FactoryBot.create(:matching, :with_project, account: contact.account, project_trait: :with_publish_datetime).tap do
      MatchingEvent.delete_all
    end
  end
  let(:contact) { FactoryBot.create(:contact, :fc) }
  let(:sf_contact) { FactoryBot.build_stubbed(:sf_contact, :fc) }
  let(:mws_user) { Salesforce::User.new(Email: 'test@example.com') }

  before do
    allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
    allow_any_instance_of(Restforce::Concerns::API).to receive(:select).and_return(mws_user)
  end

  describe '#perform' do
    let(:job) { MatchingStatusCheckJob.new }

    context 'with sending email' do
      let!(:matching_event) { FactoryBot.create(:matching_event, matching:, root: :self_recommend_fcweb, old_status: nil, new_status: :candidate) }

      it do
        expect do
          perform_enqueued_jobs do
            job.perform
          end
        end.to change(MatchingMailer.deliveries, :count).by(1)
      end

      it do
        expect do
          job.perform
        end.to change(MatchingEvent, :count).from(1).to(0)
      end
    end

    context 'without sending email' do
      let!(:matching_event) { FactoryBot.create(:matching_event, matching:, root: :self_recommend_fcweb, old_status: :candidate, new_status: :candidate) }

      it do
        expect do
          perform_enqueued_jobs do
            job.perform
          end
        end.to not_change(MatchingMailer.deliveries, :count)
      end

      it do
        expect do
          job.perform
        end.to change(MatchingEvent, :count).from(1).to(0)
      end
    end

    context 'without matching' do
      let!(:matching_event) do
        FactoryBot.create(:matching_event, :skip_validation, matching_id: 'missing', root: :self_recommend_fcweb, old_status: nil, new_status: :candidate)
      end

      it do
        expect do
          job.perform
        end.to not_change(MatchingEvent, :count).from(1)
      end
    end

    context 'without project' do
      let!(:matching_event) do
        FactoryBot.create(:matching_event, matching:, root: :self_recommend_fcweb, old_status: nil, new_status: :candidate)
      end
      let(:matching) { FactoryBot.create(:matching, :with_account, :skip_validation) }

      it do
        expect do
          job.perform
        end.to not_change(MatchingEvent, :count)
      end
    end

    context 'with error' do
      let!(:matching_event) do
        FactoryBot.create(:matching_event, matching:, root: :self_recommend_fcweb, old_status: nil, new_status: :candidate)
      end
      let(:project) { FactoryBot.create(:project) }
      let(:matching) do
        FactoryBot.create(:matching, :with_account, :skip_validation, project:)
      end

      before do
        stub = Class.new(MatchingEvent) do
          def notify_to_fc_user
            raise 'error'
          end
        end
        stub_const('MatchingEvent', stub)
      end

      it do
        expect do
          job.perform
        end.not_to raise_error
      end

      it do
        expect do
          job.perform
        end.to not_change(MatchingEvent, :count)
      end
    end
  end
end
