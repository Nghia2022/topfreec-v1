# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'FcUsers::Registrations', type: :request do
  subject do
    send_request
    response
  end

  describe 'GET /register' do
    it_behaves_like 'redirect with status moved permanently'
  end

  describe 'GET /register/' do
    it do
      is_expected.to have_http_status(:ok)
    end

    it do
      expect(subject.body).not_to have_content('conversion')
    end

    it do
      expect(subject.body).to have_selector(:testid, 'fc_users/registrations')
    end

    it do
      expect(subject.body).to have_link('個人情報の取り扱い', href: mirai_works_privacy_entry_url)
    end

    context 'when fc_user is already logged in' do
      let(:fc_user) { FactoryBot.create(:fc_user, :activated) }

      before do
        sign_in(fc_user)
      end

      it do
        is_expected.to redirect_to(mypage_fc_root_path)
      end
    end
  end

  describe 'GET /register/thanks' do
    before do
      inject_session(registered_lead_sfid:)
    end

    context 'with valid session' do
      let(:registered_lead_sfid) { 1 }

      it do
        is_expected.to have_http_status(:ok)
      end

      it do
        expect(subject.body)
          .to have_content('conversion')
          .and have_link('レジュメを送信する', href: 'https://freeconsultant.secure.force.com/ResumeUploadPageFCWeb?id=1')
          .and have_selector(:testid, 'fc_users/registrations')
      end
    end

    context 'with invalid session' do
      let(:registered_lead_sfid) { nil }

      it do
        expect do
          subject
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'POST /register/' do
    context 'valid params' do
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
          work_location1:  Fc::UserRegistration::FcUser.work_location1.values.sample
        }
      end

      context 'when confirming' do
        let(:params) do
          {
            fc_user: {
              confirming: ''
            }.merge(valid_attributes)
          }
        end

        it { is_expected.to have_http_status(:ok) }

        it do
          expect(subject.body).to have_selector(:testid, 'fc_users/registrations')
        end
      end

      context 'when submit' do
        let(:params) do
          {
            fc_user: {
              confirming: '1'
            }.merge(valid_attributes)
          }
        end

        let(:lead_sobject) { Restforce::SObject.new(Type: 'Lead', Id: 'fakeid', Email: valid_attributes[:email], LeadId__c: '1234567') }

        before do
          allow(Salesforce::Lead).to receive(:find_or_create_by).and_return(lead_sobject)
        end

        it do
          is_expected.to have_http_status(:found)
            .and redirect_to(thanks_fc_user_registration_path)
        end
      end
    end

    context 'invalid params' do
      let(:invalid_attributes) { {} }

      context 'when confirming' do
        let(:params) do
          {
            fc_user: {
              confirming: ''
            }.merge(invalid_attributes)
          }
        end

        it do
          send_request
          expect(response.body).to have_content('正しく入力されていない項目があります。')
        end
      end

      context 'when submit' do
        let(:params) do
          {
            fc_user: {
              confirming: '1'
            }.merge(invalid_attributes)
          }
        end

        let(:lead_sobject) { Restforce::SObject.new(Type: 'Lead', Id: 'fakeid', Email: Faker::Internet.email, LeadId__c: '1234567') }

        before do
          allow(Salesforce::Lead).to receive(:find_or_create_by).and_return(lead_sobject)
        end

        it do
          send_request
          expect(response.body).to have_content('正しく入力されていない項目があります。')
        end
      end
    end
  end
end
