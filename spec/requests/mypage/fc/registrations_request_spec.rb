# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mypage::Fc::Registrations', type: :request do
  subject do
    send_request
    response
  end

  let(:response_body) { subject.body }

  shared_examples 'registration already completed' do
    let(:fc_user) { FactoryBot.create(:fc_user, :activated, registration_completed_at: 1.day.ago) }

    before do
      sign_in(fc_user)
    end

    it do
      is_expected.to redirect_to mypage_fc_root_path
    end
  end

  let(:sf_account_fc) { FactoryBot.build(:sf_account_fc) }

  describe 'GET /mypage/fc/register' do
    let(:sf_contact) { FactoryBot.build_stubbed(:sf_contact, :fc) }

    context 'valid main registration flow' do
      let(:fc_user) { FactoryBot.create(:fc_user, :activated, registration_completed_at: nil) }

      before do
        stub_salesforce_request
        allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
        allow_any_instance_of(Account).to receive(:to_sobject).and_return(sf_account_fc)
        allow_any_instance_of(Restforce::Concerns::API).to receive(:select)
        sign_in(fc_user)
      end

      it do
        is_expected.to have_http_status(:success)
      end

      it do
        expect(response_body).to have_selector(:testid, 'mypage/fc/registrations')
      end

      # TODO: #3353 削除
      describe ':new_work_category of Feature Switch' do
        context 'with true' do
          before do
            Flipper.enable :new_work_category
          end

          it do
            expect(response_body)
              .to have_selector(:testid, 'mypage/fc/registrations/show#new_work_category')
          end
        end

        context 'with false' do
          it do
            expect(response_body)
              .not_to have_selector(:testid, 'mypage/fc/registrations/show#new_work_category')
          end
        end
      end
    end

    context 'registration already completed' do
      it_behaves_like 'registration already completed'
    end
  end

  describe 'POST /mypage/fc/register' do
    let(:sf_contact) { FactoryBot.build_stubbed(:sf_contact, :fc) }
    let(:fc_user) { FactoryBot.create(:fc_user, :activated, registration_completed_at: nil) }

    before do
      stub_salesforce_request
      allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
      allow_any_instance_of(Account).to receive(:to_sobject).and_return(sf_account_fc)
      allow_any_instance_of(Restforce::Concerns::API).to receive(:select)
      sign_in(fc_user)
    end

    context 'valid main registration flow' do
      let(:contact) { fc_user.contact }
      let(:valid_params) do
        {
          zipcode:               '1234567',
          prefecture:            JpPrefecture::Prefecture.all.sample.name,
          city:                  Faker::Address.street_address,
          start_timing:          Date.current,
          work_location1:        Contact::WorkPrefecture1.all.map(&:value).sample,
          business_form:         DesiredCondition.business_form_options.sample(2).map(&:first),
          occupancy_rate:        80,
          reward_min:            10,
          reward_desired:        50,
          experienced_works_sub: WorkCategory.pluck(:sub_category).flatten.sample(rand(1..4)),
          desired_works_sub:     WorkCategory.pluck(:sub_category).flatten.sample(rand(1..4))
        }
      end
      let(:params) { { fc_user: valid_params } }

      it do
        is_expected.to redirect_to mypage_fc_root_path
      end

      it do
        expect do
          send_request
          contact.reload
        end.to change(contact, :work_prefecture1__c).to(valid_params[:work_location1])
          .and change(contact, :work_options__c).to(valid_params[:business_form])
      end
    end

    context 'when missing required params' do
      let(:params) { { fc_user: invalid_params } }
      let(:invalid_params) do
        {
          zipcode:               '',
          prefecture:            '',
          city:                  '',
          start_timing:          '',
          work_location1:        '',
          occupancy_rate:        '',
          reward_desired:        '',
          experienced_works_sub: WorkCategory.pluck(:sub_category).flatten.sample(101),
          desired_works_sub:     WorkCategory.pluck(:sub_category).flatten.sample(101)
        }
      end

      it do
        is_expected.to have_http_status(:unprocessable_entity)
      end

      # TODO: #3353 Flipperの分岐を無くして1つにする
      context 'when the feature flag :new_work_category is true' do
        before do
          Flipper.enable :new_work_category
        end

        it do
          expect(response_body)
            .to have_content('郵便番号を入力してください')
            .and have_content('都道府県を入力してください')
            .and have_content('市区町村・番地を入力してください')
            .and have_content('参画可能予定日を入力してください')
            .and have_content('第一希望を入力してください')
            .and have_content('希望稼働率を入力してください')
            .and have_content('報酬金額を入力してください')
            .and have_content('選択できる得意領域数は100件を上限としております。')
            .and have_content('選択できる希望領域数は100件を上限としております。')
        end
      end

      context 'when the feature flag :new_work_category is false' do
        it do
          expect(response_body)
            .to have_content('郵便番号を入力してください')
            .and have_content('都道府県を入力してください')
            .and have_content('市区町村・番地を入力してください')
            .and have_content('参画可能予定日を入力してください')
            .and have_content('第一希望を入力してください')
            .and have_content('希望稼働率を入力してください')
            .and have_content('報酬金額を入力してください')
        end
      end
    end

    context 'registration already completed' do
      it_behaves_like 'registration already completed'
    end
  end
end
