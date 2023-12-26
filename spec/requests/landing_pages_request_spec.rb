# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'LandingPages', type: :request do
  subject(:perform_request) do
    send_request
    response
  end

  let(:send_request) do
    send(
      http_method,
      Addressable::URI.encode(path),
      headers: env,
      params:  request_body
    )
  end
  let(:headers) do
    {
      'User-Agent' => user_agent
    }
  end
  let(:user_agent) { Faker::Internet.user_agent(vendor: :chrome) }

  shared_examples 'Landing Page' do
    describe 'GET /lp/:lp_name' do
      it do
        is_expected.to redirect_to(landing_page_path(lp_name))
      end
    end

    describe 'GET /lp/:lp_name/' do
      it do
        is_expected.to have_http_status(:ok)
      end
    end

    describe 'PUT /lp/:lp_name/' do
      let(:valid_attributes) do
        last_name = Faker::Japanese::Name.last_name
        first_name = Faker::Japanese::Name.first_name

        {
          last_name:,
          first_name:,
          last_name_kana:  last_name.yomi,
          first_name_kana: first_name.yomi,
          email:           Faker::Internet.email,
          phone:           '01234567890',
          work_area1:      LandingPages::RegistrationForm.work_area1.values.sample
        }
      end

      context 'with valid params' do
        let(:params) do
          {
            fc_user: valid_attributes
          }
        end

        let(:lead_sobject) { Restforce::SObject.new(Type: 'Lead', Id: 'fakeid', Email: valid_attributes[:email], LeadId__c: '1234567') }
        let(:landing_page) { LandingPage.find_by(name: lp_name) }

        before do
          allow(Salesforce::Lead).to receive(:find_or_create_by).and_return(lead_sobject)
        end

        it do
          is_expected.to redirect_to(finish_landing_page_path(lp_name))
        end

        it do
          send_request
          expect(Salesforce::Lead).to have_received(:find_or_create_by).with(
            {
              LastName:                        valid_attributes[:last_name],
              firstName:                       valid_attributes[:first_name],
              Kana_Sei__c:                     valid_attributes[:last_name_kana],
              Kana_Mei__c:                     valid_attributes[:first_name_kana],
              Email:                           valid_attributes[:email],
              Phone:                           valid_attributes[:phone],
              WorkLocation__c:                 "1-#{valid_attributes[:work_area1].text}",
              Web_Anken_ID__c:                 '',
              LeadSource:                      'WEB',
              user_agent__c:                   'PC',
              AD_EBiS_member_name__c:          request.session.id,
              Career_Declaration_Confirmed__c: true,
              Agreement1__c:                   true,
              Agreement3__c:                   true,
              **landing_page.to_sf_lead_hash
            }
          )
        end

        context 'with pc user agent' do
          let(:user_agent) { Faker::Internet.user_agent(vendor: :chrome) }

          it do
            send_request
            expect(Salesforce::Lead).to have_received(:find_or_create_by).with(
              a_hash_including(user_agent__c: 'PC')
            )
          end
        end

        context 'with mobile user agent' do
          let(:user_agent) { Faker::Internet.user_agent(vendor: :android) }

          it do
            send_request
            expect(Salesforce::Lead).to have_received(:find_or_create_by).with(
              a_hash_including(user_agent__c: 'SP')
            )
          end
        end
      end

      context 'with invalid params' do
        let(:params) do
          {
            fc_user: {
              last_name:  '',
              first_name: ''
            }
          }
        end

        describe 'represent show view' do
          it do
            is_expected.to have_http_status(:ok)
          end

          describe 'with errors' do
            subject { perform_request.body }

            it do
              is_expected.to have_content('もう一度ご入力ください。')
            end
          end
        end
      end
    end

    describe 'GET /lp/:lp_name/finish' do
      before do
        inject_session(landing_pages_finish:)
      end

      context 'with valid session' do
        let(:landing_pages_finish) { lp_name }

        it do
          is_expected.to have_http_status(:ok)
        end
      end

      context 'with invalid session' do
        let(:landing_pages_finish) { nil }

        it do
          expect do
            subject
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end

  describe 'フリーコンサルタント' do
    let(:lp_name) { 'フリーコンサルタント' }

    it_behaves_like 'Landing Page'
  end

  describe 'フリーコンサルタント関西' do
    let(:lp_name) { 'フリーコンサルタント関西' }

    it_behaves_like 'Landing Page'
  end

  describe 'PMPMOコンサルタント' do
    let(:lp_name) { 'PMPMOコンサルタント' }

    it_behaves_like 'Landing Page'
  end

  describe 'SAPコンサルタント' do
    let(:lp_name) { 'SAPコンサルタント' }

    it_behaves_like 'Landing Page'
  end

  describe 'gmo' do
    let(:lp_name) { 'gmo' }

    it_behaves_like 'Landing Page'
  end

  describe 'pmo' do
    let(:lp_name) { 'pmo' }

    it_behaves_like 'Landing Page'
  end

  describe 'engineer' do
    let(:lp_name) { 'engineer' }

    it_behaves_like 'Landing Page'
  end

  context 'with invalid lp_name' do
    around do |ex|
      Rails.application.env_config['action_dispatch.show_exceptions'] = true
      Rails.application.env_config['action_dispatch.show_detailed_exceptions'] = false

      ex.run

      Rails.application.env_config['action_dispatch.show_exceptions'] = false
      Rails.application.env_config['action_dispatch.show_detailed_exceptions'] = true
    end

    describe 'GET /lp/:lp_name/' do
      let(:lp_name) { '存在しないLP' }

      it { is_expected.to have_http_status(:not_found) }
    end
  end
end
