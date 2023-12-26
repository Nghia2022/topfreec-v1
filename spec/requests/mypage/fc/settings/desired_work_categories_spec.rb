# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mypage::Fc::Settings::DesiredWorkCategories', type: :request do
  subject do
    send_request
    response
  end

  let(:response_body) { subject.body }

  let!(:fc_user) { FactoryBot.create(:fc_user, :activated) }
  let!(:person) { fc_user.person }

  describe 'GET /mypage/fc/settings/desired_work_category/edit' do
    before do
      sign_in(fc_user)
    end

    it do
      is_expected.to have_http_status(:ok)
    end
  end

  describe 'PUT /mypage/fc/settings/desired_work_category' do
    before do
      sign_in(fc_user)
    end

    context 'with valid' do
      let(:params) do
        {
          desired_work_categories: {
            desired_works_sub: WorkCategory.pluck(:sub_category).flatten.sample(rand(1..4)).push('')
          }
        }
      end
      let(:main_categories) { WorkCategory.group_sub_categories(params[:desired_work_categories][:desired_works_sub]).keys }

      it do
        is_expected.to redirect_to mypage_fc_profile_path
      end

      describe 'update record' do
        it do
          expect do
            send_request
            person.reload
          end.to change(person, :desired_works_sub__c).to(params[:desired_work_categories][:desired_works_sub].compact_blank)
            .and change(person, :desired_works_main__c).to(main_categories)
        end
      end
    end

    context 'with invalid' do
      let(:params) do
        {
          desired_work_categories: {
            desired_works_sub: ''
          }
        }
      end

      it do
        is_expected.to have_http_status(:unprocessable_entity)
      end

      it do
        expect(response_body)
          .to have_content('選択できる領域数は100件を上限としております。')
      end
    end
  end
end
