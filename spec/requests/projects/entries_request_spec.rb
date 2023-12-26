# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Projects::Entry', type: :request do
  subject(:perform_request) do
    send_request
    response
  end

  let(:project) { FactoryBot.create(:project, :with_client, :with_publish_datetime) }
  let(:project_id) { project.to_param }

  shared_context 'signed in fc_user' do
    let(:fc_user) { FactoryBot.create(:fc_user, :activated) }
    let(:account) { fc_user.account }
    let!(:contact) { fc_user.contact }
    let(:sf_contact) { FactoryBot.build(:sf_contact) }
    let(:sf_account) { FactoryBot.build(:sf_account_fc) }

    before do
      allow(fc_user.contact).to receive(:to_sobject).and_return(sf_contact)
      allow(fc_user.account).to receive(:to_sobject).and_return(sf_account)
      sign_in(fc_user)
    end
  end

  describe 'GET /job/:project_id/entry/new' do
    context 'signed in' do
      include_context 'signed in fc_user'

      it do
        is_expected.to have_http_status(:ok)
      end

      describe 'content' do
        let!(:account) do
          fc_user.account.tap { |account| account.update!(release_yotei__c: Time.current) }
        end

        subject do
          send_request
          response.body
        end

        it do
          is_expected.to have_button('応募する')
            .and have_selector(:testid, 'projects/entries')
        end

        context 'when adjust_start_timing is disabled' do
          it do
            is_expected.to have_selector("input[value='#{account.release_yotei__c}']")
          end
        end

        context 'when adjust_start_timing is enabled' do
          before do
            FeatureSwitch.enable :adjust_start_timing
          end

          it do
            is_expected.to have_selector("input[value='#{1.day.since(account.release_yotei__c)}']")
          end
        end
      end
    end

    context 'not signed in' do
      pending
    end
  end

  describe 'POST /job/:project_id/entry' do
    let(:valid_params) do
      {
        matching: {
          start_timing:   1.day.after.to_date,
          occupancy_rate: 100,
          reward_desired: 100,
          reward_min:     10
        }
      }
    end

    context 'valid' do
      include_context 'signed in fc_user'

      let(:params) { valid_params }

      it do
        is_expected.to have_http_status(:created)
          .and(satisfy { |response| response.headers['Location'] == thanks_entry_path })
      end

      it do
        expect { send_request }.to change(account.matchings, :count).by(1)
      end

      describe 'apply notification' do
        it do
          expect do
            send_request
          end.to change(Notification, :count).by(1)
            .and change(Receipt, :count).by(1)
        end

        describe 'notification' do
          subject do
            perform_request
            Notification.last
          end

          it do
            is_expected.to have_attributes(subject: '残り6/7件応募可能です')
          end
        end
      end
    end

    context 'limit exeeded' do
      include_context 'signed in fc_user'

      let(:params) { valid_params }

      let(:account) { fc_user.account }
      let!(:contact) { FactoryBot.create(:contact, account:) }
      let(:sf_contact) { FactoryBot.build(:sf_contact) }
      let!(:matchings) { FactoryBot.create_list(:matching, 7, :with_project, account:, project_trait:) }
      let(:project_trait) { [:with_publish_datetime] }

      it do
        is_expected.to have_http_status(:unprocessable_entity)
      end

      it do
        send_request
        expect(subject.body).to match I18n.t('base.limit_exceeded', scope: 'activerecord.errors.models.matching.attributes', entry_limit: Settings.entry_limit)
      end

      it do
        expect { send_request }.to change(account.matchings.for_entry_count, :count).by(0)
      end
    end

    context 'when exist entry' do
      include_context 'signed in fc_user'

      let(:params) { valid_params }

      let(:account) { fc_user.account }
      let!(:contact) { FactoryBot.create(:contact, account:) }
      let(:sf_contact) { FactoryBot.build(:sf_contact) }
      let!(:matching) { FactoryBot.create(:matching, project:, account:, matching_status__c: matching_status) }

      context 'when matching_status__c is effective' do
        let(:matching_status) { :candidate }

        it do
          expect { send_request }.to raise_error(Pundit::NotAuthorizedError)
        end
      end

      context 'when matching_status__c is ineffective' do
        let(:matching_status) { :lost }

        it do
          expect { send_request }.not_to raise_error
        end
      end
    end

    context 'when entry is closed' do
      include_context 'signed in fc_user'

      let(:params) { valid_params }

      let(:project) { FactoryBot.create(:project, :with_client, isclosedwebreception__c: true) }

      it do
        expect { send_request }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context 'when invalid params' do
      include_context 'signed in fc_user'

      let(:params) { valid_params.deep_merge(matching: { start_timing: nil }) }

      it do
        is_expected.to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET /job/entry/thanks' do
    context 'if not signed in' do
      it do
        is_expected.to have_http_status :redirect
      end
    end

    context 'if signed in' do
      include_context 'signed in fc_user'

      it do
        is_expected.to have_http_status :ok
      end
    end
  end
end
