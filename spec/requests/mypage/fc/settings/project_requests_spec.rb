# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mypage::Fc::Settings::ProjectRequests', :erb, type: :request do
  subject do
    send_request
    response
  end

  let(:response_body) { subject.body }

  let!(:fc_user) { FactoryBot.create(:fc_user, :activated) }
  let!(:account) { fc_user.account }
  let!(:person) { fc_user.person }

  describe 'GET /mypage/fc/settings/project_request/edit' do
    let!(:account) do
      fc_user.account.tap { |account| account.update!(release_yotei__c: Time.current) }
    end

    before do
      sign_in(fc_user)
    end

    it do
      is_expected.to have_http_status(:ok)
    end

    context 'when adjust_start_timing is disabled' do
      it do
        expect(response_body).to have_selector("input[value='#{account.release_yotei__c}']")
      end
    end

    context 'when adjust_start_timing is enabled' do
      before do
        FeatureSwitch.enable :adjust_start_timing
      end

      it do
        expect(response_body).to have_selector("input[value='#{1.day.since(account.release_yotei__c)}']")
      end
    end
  end

  describe 'PUT /mypage/fc/settings/project_request' do
    before do
      sign_in(fc_user)
    end

    let(:valid_params) do
      {
        project_request: {
          start_timing:   Date.current,
          reward_min:     50,
          reward_desired: 50,
          occupancy_rate: 80
        }
      }
    end

    context 'valid' do
      let(:params) do
        valid_params
      end

      it do
        is_expected.to redirect_to mypage_fc_profile_path
      end

      shared_examples 'update record' do
        it do
          project_request_params = params[:project_request]

          expect do
            send_request
            account.reload
            person.reload
          end.to change(account, :release_yotei__c).to(release_yotei__c)
            .and change(account, :saitei_hosyu__c).to(project_request_params[:reward_min])
            .and change(account, :kibo_hosyu__c).to(project_request_params[:reward_desired])
            .and change(account, :kado_ritsu__c).to(project_request_params[:occupancy_rate])
            .and change(account, :kakunin_bi__c).to(Date.current)
            .and change(account, :release_yotei_kakudo__c).to('確定')
        end
      end

      context 'when adjust_start_timing is disabled' do
        let(:release_yotei__c) { params[:project_request][:start_timing].to_date }

        include_examples 'update record'
      end

      context 'when adjust_start_timing is enabled' do
        let(:release_yotei__c) { 1.day.ago(params[:project_request][:start_timing].to_date) }

        before do
          FeatureSwitch.enable :adjust_start_timing
        end

        include_examples 'update record'
      end
    end

    context 'invalid' do
      context 'when blank' do
        let(:params) do
          {
            project_request: {
              start_timing:   '',
              reward_min:     '',
              reward_desired: '',
              occupancy_rate: ''
            }
          }
        end

        it do
          is_expected.to have_http_status(:unprocessable_entity)
        end

        it do
          expect(response_body)
            .to  have_content('参画可能予定日を入力してください')
            .and have_content('検討可能額を入力してください')
            .and have_content('希望額を入力してください')
            .and have_content('希望稼働率を入力してください')
        end
      end
      context 'when lower 1000' do
        let(:params) do
          {
            project_request: {
              reward_min:     '1000',
              reward_desired: '1000'
            }
          }
        end

        it do
          is_expected.to have_http_status(:unprocessable_entity)
        end

        it do
          expect(response_body)
            .to have_content('検討可能額は1000より小さい値にしてください')
            .and have_content('希望額は1000より小さい値にしてください')
        end
      end
    end
  end
end
