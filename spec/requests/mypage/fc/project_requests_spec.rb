# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mypage::Fc::ProjectRequests', :erb, type: :request do
  subject do
    send_request
    response
  end

  let(:response_body) { subject.body }

  let!(:fc_user) { FactoryBot.create(:fc_user, :activated) }
  let!(:account) { fc_user.account }
  let!(:person) { fc_user.person }

  before do
    sign_in(fc_user)
  end

  describe 'GET /mypage/fc/project_request/edit' do
    let!(:account) do
      fc_user.account.tap { |account| account.update!(release_yotei__c: Time.current) }
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

  describe 'PUT /mypage/fc/project_request' do
    let(:valid_params) do
      {
        project_request: {
          start_timing:   Date.current,
          occupancy_rate: 80,
          reward_desired: 100,
          reward_min:     10
        }
      }
    end

    context 'valid' do
      let(:params) do
        valid_params
      end

      it do
        is_expected.to have_http_status(:ok)
      end

      shared_examples 'update record' do
        it do
          project_request_params = params[:project_request]

          expect do
            send_request
            account.reload
            person.reload
          end.to change(account, :release_yotei__c).to(release_yotei__c)
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
      let(:params) do
        {
          project_request: {
            start_timing:   '',
            occupancy_rate: ''
          }
        }
      end

      it do
        is_expected.to have_http_status(:unprocessable_entity)
      end
    end
  end
end
