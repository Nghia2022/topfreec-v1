# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Projects', :erb, type: :request do
  subject(:perform) do
    send_request
    response
  end

  let(:response_body) { perform.body }
  let(:fc_user) { FactoryBot.create(:fc_user, :activated) }
  let(:account) { fc_user.account }
  let(:sf_account_fc) { FactoryBot.build(:sf_account_fc) }

  before do
    stub_salesforce_request
    allow_any_instance_of(Account).to receive(:to_sobject).and_return(sf_account_fc)
  end

  describe 'GET /project' do
    context 'without search' do
      let!(:model) { FactoryBot.create_list(:project, 3, :with_client).map(&:decorate) }

      it do
        is_expected.to have_http_status(:ok)
      end
    end

    context 'with compensation' do
      let(:compensation) { Compensation.first }
      let!(:matched_project) { FactoryBot.create(:project, web_reward_min__c: compensation.min + 1).decorate }
      let!(:unmatched_project) { FactoryBot.create(:project, web_reward_min__c: compensation.min - 1).decorate }

      let(:params) { { compensation_ids: [compensation.id] } }

      it { expect(response_body).to have_content(matched_project.project_name) }
      it { expect(response_body).not_to have_content(unmatched_project.project_name) }

      context 'when invalid compensation_id' do
        let(:params) { { compensation_id: 'invalid' } }

        it do
          is_expected.to have_http_status(:ok)
        end
      end
    end

    context 'with category' do
      let(:category) { Project::ExperienceCategory.first }
      let!(:matched_project) { FactoryBot.create(:project, experiencecatergory__c: [category.value]).decorate }
      let!(:unmatched_project) { FactoryBot.create(:project).decorate }

      let(:params) { { categories: [category.value] } }

      it { expect(response_body).to have_content(matched_project.project_name) }
      it { expect(response_body).not_to have_content(unmatched_project.project_name) }

      describe 'meta tags' do
        subject(:doc) do
          Capybara.string(response_body)
        end

        describe ':new_project_category_meta of Feature Switch' do
          # TODO: #3440 FeatureSwitchの分岐を無くして1つにする
          context 'with true' do
            before do
              FeatureSwitch.enable :new_project_category_meta
            end

            let!(:project_category_metum) do
              FactoryBot.create(
                :project_category_metum,
                work_category_main: category.value,
                slug:               category.slug,
                title:              "#{category.value} Title",
                description:        "#{category.value} Description",
                keywords:           "#{category.value} Keywords"
              )
            end

            let(:category_metum) do
              ProjectCategoryMetum.fetch_by_or_null({ work_category_main: category.value })
            end

            it do
              is_expected.to have_title(/#{category_metum.title}/)
                .and(satisfy { doc.find('meta[name=description]', visible: false)[:content] == category_metum.description })
                .and(satisfy { doc.find('meta[name=keywords]', visible: false)[:content] == category_metum.keywords })
            end
          end

          context 'with false' do
            let(:category_metum) do
              Project::CategoryMetum.find_or_null(category.value)
            end

            it do
              is_expected.to have_title(/#{category.value}/)
                .and(satisfy { doc.find('meta[name=description]', visible: false)[:content] == category_metum.description })
                .and(satisfy { doc.find('meta[name=keywords]', visible: false)[:content] == category_metum.keywords })
            end
          end
        end

        describe 'canonical' do
          # TODO: #3440 FeatureSwitchを削除
          before do
            FeatureSwitch.enable :new_project_category_meta
          end

          let!(:project_category_metum) do
            FactoryBot.create(
              :project_category_metum,
              work_category_main: category.value,
              slug:               category.slug
            )
          end

          let(:category_metum) do
            ProjectCategoryMetum.fetch_by_or_null({ work_category_main: category.value })
          end

          context 'with only one cateogry' do
            it do
              is_expected.to(satisfy { doc.find('link[rel=canonical]', visible: false)[:href] == slug_projects_url(project_category_metum.slug) })
            end
          end

          context 'with some cateogries' do
            let(:params) { { categories: %W[#{category.value} OtherMainCategory] } }

            it { is_expected.not_to have_css('link[rel=canonical]', visible: false) }
          end
        end
      end
    end

    context 'with :slug' do
      let(:slug) { 'project-management' }
      let(:params) { { slug: } }

      # TODO: #3440 FeatureSwitchの分岐を無くして1つにする
      context 'when :new_project_category_meta of Feature Switch is true' do
        before do
          FeatureSwitch.enable :new_project_category_meta
        end

        let!(:project_category_metum) do
          FactoryBot.create(
            :project_category_metum,
            work_category_main: 'プロジェクト管理',
            title:              'プロジェクト管理 Title',
            description:        'プロジェクト管理 Description',
            keywords:           'プロジェクト管理 Keywords',
            slug:
          )
        end
        let!(:matched_project) { FactoryBot.create(:project, experiencecatergory__c: [project_category_metum.work_category_main]).decorate }
        let!(:unmatched_project) { FactoryBot.create(:project).decorate }

        it { expect(response_body).to have_content(matched_project.project_name) }
        it { expect(response_body).to have_link("#{project_category_metum.category_name}案件検索結果一覧", href: slug_projects_path(project_category_metum.slug)) }
        it { expect(response_body).to have_content("#{project_category_metum.category_name} 案件検索結果") }
        it { expect(response_body).not_to have_content(unmatched_project.project_name) }

        describe 'meta tags' do
          subject(:doc) do
            Capybara.string(response_body)
          end

          context 'with true' do
            it do
              is_expected.to have_title(/#{project_category_metum.work_category_main}/)
                .and(satisfy { doc.find('meta[name=description]', visible: false)[:content] == project_category_metum.description })
                .and(satisfy { doc.find('meta[name=keywords]', visible: false)[:content] == project_category_metum.keywords })
            end
          end
        end
      end

      context 'when :new_project_category_meta of Feature Switch is false' do
        it { is_expected.to redirect_to(projects_path) }
      end
    end
  end

  describe 'GET /job/:id' do
    let(:id) { project.to_param }
    let(:project) { FactoryBot.create(:project) }
    let!(:fc_user) { FactoryBot.create(:fc_user, :activated) }
    let(:contact) { fc_user.contact }
    let(:now) { '2020-10-01 23:59:00'.in_time_zone }
    let(:tomorrow) { '2020-10-02 00:00:00'.in_time_zone }
    let(:params) { { key: 'value' } }

    around do |ex|
      travel_to(now) { ex.run }
    end

    before do
      sign_in(fc_user)
    end

    it do
      is_expected.to have_http_status(:ok)
    end

    it do
      get projects_path
      travel_to(tomorrow)
      expect do
        send_request
      end.to change { contact.reload.fcweb_logindatetime__c }.from(now).to(tomorrow)
    end

    describe 'content' do
      it do
        expect(response_body).to have_selector('h1', text: project.web_projectname__c)
          .and have_link(href: projects_path(key: 'value'))
      end
    end

    describe 'JobPosting' do
      let(:project) { FactoryBot.create(:project, jobposting_isactive__c: jobposting_is_active) }

      context 'when jobposting is actived' do
        let(:jobposting_is_active) { true }

        it 'includes meta data' do
          expect(response_body).to include '<script type="application/ld+json">'
        end
      end

      context 'when jobposting is inactived' do
        let(:jobposting_is_active) { false }

        it 'not includes meta data' do
          expect(response_body).not_to include '<script type="application/ld+json">'
        end
      end
    end
  end

  describe 'GET /project/featured' do
    let!(:model) { FactoryBot.create_list(:project, 2, :with_client, :with_impressions).map(&:decorate) }

    before { ProjectDailyPageView.refresh }

    it do
      is_expected.to have_http_status(:ok)
    end

    it do
      expect(response_body).to have_content('注目案件一覧')
        .and have_content(model.first.project_name)
    end
  end
end
