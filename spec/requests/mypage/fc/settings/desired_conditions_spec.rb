# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mypage::Fc::Settings::DesiredConditions', :erb, type: :request do
  subject do
    send_request
    response
  end

  let(:response_body) { subject.body }

  let!(:fc_user) { FactoryBot.create(:fc_user, :activated) }
  let!(:person) { fc_user.person }

  describe 'GET /mypage/fc/settings/desired_condition/edit' do
    before do
      sign_in(fc_user)
    end

    it do
      is_expected.to have_http_status(:ok)
    end
  end

  describe 'PUT /mypage/fc/settings/desired_condition' do
    before do
      sign_in(fc_user)
    end

    # TODO: #3353 不要なパラメータの削除
    let(:valid_params) do
      {
        desired_condition: {
          experienced_works: Contact::ExperiencedWork.all.map(&:value).sample(rand(1..4)),
          desired_works:     Contact::DesiredWork.all.map(&:value).sample(rand(1..4)),
          company_sizes:     DesiredCondition.company_sizes.options.shuffle.take(rand(1..4)).map(&:first),
          work_location1:    Contact::WorkPrefecture1.all.map(&:value).sample,
          work_location2:    Contact::WorkPrefecture2.all.map(&:value).sample,
          work_location3:    Contact::WorkPrefecture3.all.map(&:value).sample
        }
      }
    end

    context 'with valid' do
      let(:params) do
        valid_params
      end

      it do
        is_expected.to redirect_to mypage_fc_profile_path
      end

      describe 'update record' do
        it do
          desired_condition_params = params[:desired_condition]

          expect do
            send_request
            person.reload
          end.to change(person, :experienced_works__c).to(desired_condition_params[:experienced_works])
            .and change(person, :desired_works__c).to(desired_condition_params[:desired_works])
            .and change(person, :experienced_company_size__c).to(desired_condition_params[:company_sizes])
            .and change(person, :work_prefecture1__c).to(desired_condition_params[:work_location1])
            .and change(person, :work_prefecture2__c).to(desired_condition_params[:work_location2])
            .and change(person, :work_prefecture3__c).to(desired_condition_params[:work_location3])
        end
      end
    end

    context 'with invalid' do
      let(:params) do
        {
          desired_condition: {
            work_location1: ''
          }
        }
      end

      it do
        is_expected.to have_http_status(:unprocessable_entity)
      end

      it do
        expect(response_body)
          .to have_content('第一希望を入力してください')
      end
    end
  end
end
