# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Cases', type: :request do
  subject do
    send_request
    response
  end

  describe 'GET /cases/new' do
    it do
      is_expected.to have_http_status(:ok)
    end
  end

  describe 'POST /cases' do
    let(:valid_params) do
      {
        cases_case_form: {
          last_name:          '姓',
          first_name:         '名',
          last_name_kana:     'セイ',
          first_name_kana:    'メイ',
          email:              'test@example.com',
          email_confirmation: 'test@example.com',
          phone:              '0123456789',
          description:        'desc',
          case_type:          '問題'
        }
      }
    end

    context 'with valid params' do
      context 'confirming' do
        let(:params) do
          valid_params.deep_merge(cases_case_form: { confirming: '' })
        end

        it do
          is_expected.to have_http_status(:ok)
        end
      end

      context 'submit' do
        let(:params) do
          valid_params.deep_merge(cases_case_form: { confirming: '1' })
        end

        before do
          stub_salesforce_request
        end

        it do
          is_expected.to redirect_to thanks_cases_path
        end

        it do
          expect do
            perform_enqueued_jobs do
              send_request
            end
          end.to change { CaseFormMailer.deliveries.count }.by(1)
        end

        describe 'email' do
          subject { open_email('test@example.com') }

          it do
            perform_enqueued_jobs do
              send_request
            end

            is_expected.to have_subject('【みらいワークス】お問い合わせ受付')
          end
        end

        context 'back button' do
          let(:params) do
            valid_params.deep_merge(
              back:            '1',
              cases_case_form: {
                confirming: '1'
              }
            )
          end

          it do
            expect do
              send_request
            end.to change { CaseFormMailer.deliveries.count }.by(0)
          end

          it do
            send_request
            expect(response.body).to have_content('お問い合わせ内容を送信する')
          end
        end
      end
    end

    context 'with invalid params' do
      let(:params) do
        invalid_params.deep_merge(cases_case_form: { confirming: '' })
      end

      let(:invalid_params) do
        {
          cases_case_form: {
            last_name:          '',
            first_name:         '',
            last_name_kana:     '',
            first_name_kana:    '',
            email:              '',
            email_confirmation: '',
            phone:              '',
            description:        '',
            case_type:          ''
          }
        }
      end

      it do
        send_request
        expect(response.body).to have_content('名前（姓）を入力してください')
          .and have_content('名前（名）を入力してください')
          .and have_content('名前（セイ）を入力してください')
          .and have_content('名前（メイ）を入力してください')
          .and have_content('メールアドレスを入力してください')
          .and have_content('お問い合わせの種類を入力してください')
          .and have_content('お問い合わせ内容を入力してください')
      end
    end
  end
end
