# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Welcome', :erb, type: :request do
  subject(:perform) do
    send_request
    response
  end

  describe 'GET /' do
    context 'when logged in' do
      let(:sf_account_fc) { FactoryBot.build(:sf_account_fc) }

      before do
        allow(user.account).to receive(:to_sobject).and_return(sf_account_fc)
        sign_in(user)
      end

      context 'with a fc user' do
        let(:user) { FactoryBot.create(:fc_user, :activated) }

        it do
          is_expected.to have_http_status(:ok)
        end
      end

      context 'with a client user' do
        let(:user) { FactoryBot.create(:client_user) }

        it do
          is_expected.to have_http_status(:redirect)
        end
      end
    end

    context 'when signed out' do
      it do
        is_expected.to have_http_status(:ok)
      end
      it do
        expect(perform.body)
          .to have_content('FEATURED PROJECTS')
          .and include('botchan')
      end

      describe 'Featured projects' do
        before do
          Rake::Task['oneshot:create_project_category_meta'].invoke
          FeatureSwitch.enable :new_project_category_meta
        end

        let!(:not_showed_projects) do
          ProjectDecorator.decorate_collection(
            [
              # PVが少なくて表示 limit から漏れた奴
              FactoryBot.create_list(:project,
                                     2,
                                     :published,
                                     :with_impressions,
                                     created_at:       2.months.ago,
                                     impression_count: 1),
              # 当日のPVは対象外
              FactoryBot.create_list(:project,
                                     2,
                                     :published,
                                     :with_impressions,
                                     created_at:          2.months.ago,
                                     impression_count:    1,
                                     impression_datetime: Time.current)
            ].flatten
          )
        end
        let!(:showed_projects) do
          ProjectDecorator.decorate_collection(
            FactoryBot.create_list(:project,
                                   8,
                                   :published,
                                   :with_impressions,
                                   created_at:       2.months.ago,
                                   impression_count: 2)
          )
        end

        before { ProjectDailyPageView.refresh }

        it do
          expect(perform.body).to [
            *showed_projects.map { |pj| have_content(pj.project_name) },
            *not_showed_projects.map { |pj| have_no_content(pj.project_name) }
          ].inject(:and)
        end
      end
    end
  end
end
