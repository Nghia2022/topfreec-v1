# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mypage::Fc::Entries', :erb, type: :request do
  subject do
    send_request
    response
  end

  let(:response_body) { subject.body }

  let(:fc_user) { FactoryBot.create(:fc_user, :activated) }
  let(:account) { fc_user.account }

  let(:sf_account_fc) { FactoryBot.build(:sf_account_fc) }

  before do
    stub_salesforce_request
    allow_any_instance_of(Account).to receive(:to_sobject).and_return(sf_account_fc)
  end

  describe 'GET /mypage/fc/entries' do
    let(:entry_count) { 3 }
    let!(:entries) do
      FactoryBot.create_list(:matching, entry_count, :with_project, :candidate, account:, project_trait: %i[with_client with_publish_datetime]).each do |matching|
        matching.project.save
      end
    end

    before do
      sign_in(fc_user)
    end

    it do
      is_expected.to have_http_status(:ok)
    end

    it do
      send_request
      expect(response.body).to have_selector(:testid, 'mypage/fc/entry/item/row', count: entry_count)
    end

    it do
      expect(response_body).to have_selector(:testid, 'mypage/fc/entries')
    end
  end

  describe 'GET /mypage/fc/entries/:id/decline' do
    let(:matching) { FactoryBot.create(:matching, :with_project, :candidate, account:) }
    let(:id) { matching.id }

    before do
      sign_in(fc_user)
    end

    it do
      is_expected.to have_http_status(:ok)
    end

    it do
      expect(response_body).to have_selector(:testid, 'mypage/fc/entries')
    end
  end

  describe 'DELETE /mypage/fc/entries/:id' do
    let(:builder_class) do
      Class.new(Fc::Entry::MatchingMailerPresenterBuilder) do
        # :reek:UtilityFunction
        def contact
          FactoryBot.build(:sf_contact)
        end

        # :reek:UtilityFunction
        def mws_user
          Salesforce::User.new(Email: 'test@example.com')
        end
      end
    end

    before do
      MatchingMailer.deliveries.clear
      stub_const('Fc::Entry::MatchingMailerPresenterBuilder', builder_class)
      sign_in(fc_user)
    end

    context 'when matching status is entry' do
      let(:id) { matching.id }
      let!(:matching) { FactoryBot.create(:matching, :with_project, :candidate, account:, project_trait: :with_publish_datetime) }

      it do
        is_expected.to redirect_to mypage_fc_entries_path
      end

      it do
        subject
        matching.reload
        expect(matching).to have_attributes(
          matching_status__c: 'fc_declined_entry'
        )
      end

      it do
        expect do
          send_request
        end
          .to have_no_enqueued_job
          .and change(MatchingEvent, :count).by(1)
      end

      it do
        MatchingEvent.delete_all
        expect do
          perform_enqueued_jobs do
            send_request
            MatchingStatusCheckJob.perform_now
          end
        end.to change(MatchingMailer.deliveries, :count).by(1)
      end
    end

    context 'when matching status is proposed' do
      let(:id) { matching.id }
      let!(:matching) { FactoryBot.create(:matching, :with_project, :resume_submitted, account:, project_trait: :with_publish_datetime) }

      let(:valid_params) do
        {
          matching: {
            ng_reason: Faker::Lorem.paragraphs(number: rand(3..7)).join("\n")
          }
        }
      end

      context 'with valid params' do
        context 'submit' do
          let(:params) do
            valid_params
          end

          it do
            is_expected.to redirect_to mypage_fc_entries_path
          end

          it do
            subject
            matching.reload
            expect(matching).to have_attributes(
              matching_status__c: 'fc_declining',
              ng_reason:          params[:matching][:ng_reason]
            )
          end

          it do
            expect do
              send_request
            end
              .to have_no_enqueued_job
              .and change(MatchingEvent, :count).by(1)
          end

          it do
            expect do
              perform_enqueued_jobs do
                send_request
                MatchingStatusCheckJob.perform_now
              end
            end.to change(MatchingMailer.deliveries, :count).by(1)
          end
        end
      end

      context 'with invalid params' do
        context 'submit' do
          let(:params) do
            valid_params.deep_merge(matching: { ng_reason: '' })
          end

          it do
            is_expected.to have_http_status :unprocessable_entity
          end

          it do
            expect(response_body).to have_content('辞退理由を入力してください')
          end
        end
      end
    end
  end
end
