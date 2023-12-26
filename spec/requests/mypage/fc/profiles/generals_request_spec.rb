# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mypage::Fc::Profiles::Generals', :erb, type: :request do
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

  describe 'GET /mypage/fc/profile/general/edit' do
    before do
      sign_in(fc_user)
    end

    it do
      is_expected.to have_http_status(:ok)
    end
  end

  describe 'PATCH /mypage/fc/profile/general' do
    before do
      sign_in(fc_user)
    end

    let(:valid_params) do
      {
        general: {
          zipcode: '1234567'
        }
      }
    end

    context 'with valid params' do
      context 'submit' do
        let(:params) do
          valid_params
        end

        before do
          stub_salesforce_update_request('Contact', anything)
        end

        it do
          is_expected.to redirect_to mypage_fc_profile_path
        end
      end

      context 'when phone changed' do
        let(:params) do
          valid_params.deep_merge(general: { phone: new_phone })
        end
        let(:new_phone) { Faker::PhoneNumber.cell_phone.delete('-') }
        let(:payload) do
          {
            'Email' => be_present,
            'FirstName' => be_present,
            'HomePhone' => be_present,
            :Id => be_present,
            'Kana_Mei__c' => be_present,
            'Kana_Sei__c' => be_present,
            'LastName' => be_present,
            'MailingCity' => be_present,
            'MailingPostalCode' => be_present,
            'MailingState' => be_present,
            'MailingStreet' => be_present,
            'PhoneForConfirmation__c' => new_phone
          }
        end

        before do
          expect_any_instance_of(Restforce::Concerns::API).to receive(:update!).with('Contact', payload).and_return(true)
        end

        it 'send otp' do
          stub = stub_request(:post, %r{https://api.twilio.com/2010-04-01/Accounts/AC.+/Messages\.json})
          perform_enqueued_jobs do
            send_request
          end
          expect(stub).to have_been_requested
        end
      end

      context 'when phone not changed' do
        let(:params) do
          valid_params
        end
        let(:payload) do
          {
            'Email' => be_present,
            'FirstName' => be_present,
            'HomePhone' => be_present,
            :Id => be_present,
            'Kana_Mei__c' => be_present,
            'Kana_Sei__c' => be_present,
            'LastName' => be_present,
            'MailingCity' => be_present,
            'MailingPostalCode' => be_present,
            'MailingState' => be_present,
            'MailingStreet' => be_present,
            'Phone' => be_present
          }
        end
        before do
          expect_any_instance_of(Restforce::Concerns::API).to receive(:update!).with('Contact', payload).and_return(true)
        end

        it 'not send otp' do
          expect do
            perform_enqueued_jobs do
              send_request
            end
          end.to not_change(FcUserSmsMailer.deliveries, :count)
        end
      end
    end

    context 'with ignored params' do
      context 'submit' do
        let(:params) do
          last_name = Faker::Japanese::Name.last_name
          first_name = Faker::Japanese::Name.first_name

          valid_params.deep_merge(
            general: {
              last_name:,
              first__name:     first_name,
              last_name_kana:  last_name.yomi,
              first_name_kana: first_name.yomi
            }
          )
        end
        let(:payload) do
          form = Fc::EditProfile::GeneralForm.new_from_sobject_with_user(fc_user.contact.to_sobject)

          {
            'Email' => be_present,
            'FirstName' => form.FirstName,
            'HomePhone' => be_present,
            :Id => be_present,
            'Kana_Mei__c' => form.Kana_Mei__c,
            'Kana_Sei__c' => form.Kana_Sei__c,
            'LastName' => form.LastName,
            'MailingCity' => be_present,
            'MailingPostalCode' => be_present,
            'MailingState' => be_present,
            'MailingStreet' => be_present,
            'Phone' => be_present
          }
        end

        before do
          expect_any_instance_of(Restforce::Concerns::API).to receive(:update!).with('Contact', payload).and_return(true)
        end

        it do
          is_expected.to redirect_to mypage_fc_profile_path
        end
      end
    end

    context 'with invalid params' do
      context 'submit' do
        let(:params) do
          {
            general: {
              last_name:       '',
              first__name:     '',
              last_name_kana:  '',
              first_name_kana: '',
              zipcode:         '',
              phone:           ''
            }
          }
        end

        it do
          is_expected.to have_http_status(:unprocessable_entity)
        end

        it do
          expect(response_body).to have_content('郵便番号を入力してください')
            .and have_content('携帯番号を入力してください')
        end
      end
    end

    context 'when failed by salesforce custom rule' do
      context 'submit' do
        let(:params) do
          valid_params
        end
        let(:error) do
          Restforce::ErrorCode::DuplicatesDetected.new('DUPLICATES_DETECTED: いずれか 1 つのレコードを使用しますか?')
        end

        before do
          allow_any_instance_of(Restforce::Concerns::API).to receive(:update!).and_raise(error)
        end

        it do
          is_expected.to have_http_status(:unprocessable_entity)
        end

        it do
          expect(response_body).to have_content('何らかの問題が発生しました。後ほどお試しください')
        end
      end
    end
  end
end
