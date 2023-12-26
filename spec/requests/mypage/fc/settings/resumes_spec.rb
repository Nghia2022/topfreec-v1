# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mypage::Fc::Settings::Resumes', type: :request do
  subject do
    send_request
    response
  end

  let(:response_body) { subject.body }

  let(:fc_user) { FactoryBot.create(:fc_user, :activated) }
  let(:sf_contact) { FactoryBot.build(:sf_contact) }

  before do
    allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
  end

  describe 'GET /mypage/fc/settings/resumes/new' do
    before do
      sign_in(fc_user)
    end

    it do
      is_expected.to have_http_status(:ok)
    end
  end

  describe 'POST /mypage/fc/settings/resumes' do
    before do
      sign_in(fc_user)
      allow(Salesforce::ContentDocument).to receive(:create!).and_return(true)
    end

    let(:valid_params) do
      {
        resume: {
          document: fixture_file_upload('resume/valid.pptx')
        }
      }
    end

    context 'with valid params' do
      let(:params) do
        valid_params
      end

      before do
        stub_salesforce_update_request('Contact', anything)
      end

      it do
        is_expected.to have_http_status(:created)
          .and(satisfy { |response| response.headers['Location'] == mypage_fc_settings_path })
      end
    end

    context 'with invalid params' do
      context 'submit' do
        let(:params) do
          {
            resume: {
              document: ''
            }
          }
        end

        it do
          is_expected.to have_http_status(:unprocessable_entity)
        end

        it do
          expect(response_body).to have_content('レジュメを選択してください')
        end
      end
    end

    context 'with salesforce error' do
      context 'submit' do
        let(:params) do
          {
            resume: {
              document: fixture_file_upload('resume/valid.pptx')
            }
          }
        end

        before do
          allow(Salesforce::ContentDocument).to receive(:create!).and_raise(Restforce::ErrorCode::RequiredFieldMissing, nil)
        end

        it do
          is_expected.to have_http_status(:unprocessable_entity)
        end

        it do
          expect(response_body)
            .to have_content('アップロードに失敗しました')
            .and have_no_content('正しく入力されていない項目があります。')
        end
      end
    end
  end
end
