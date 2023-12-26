# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProjectsController, :erb, type: :request do
  let(:body) { response.body }
  let(:doc) { Capybara.string(body) }

  shared_examples 'メタタグの検証' do
    it '指定された値が設定される' do
      is_expected.to eq 200
      expect(body).to have_title title
      expect(doc.find('meta[name=description]', visible: false)[:content]).to eq description
      expect(doc.find('meta[name=keywords]', visible: false)[:content]).to eq keywords
    end
  end

  describe 'GET /project?:search_params' do
    context '検索条件なしの場合' do
      let(:search_params) { nil }
      let(:title) { '(test) コンサルタント案件紹介・求人｜フリーランス人材IT,戦略,PMO' }
      let(:description) { 'フリーランス人材のコンサルタント案件,プロジェクト求人。フリーコンサルタントで活躍する方にIT戦略,PMO,PM,SAP,システム開発,マーケティング,webディレクターなどコンサル案件や高額報酬,高待遇プロジェクトをご紹介。' }
      let(:keywords) { 'コンサルタント,案件,フリーランス,求人,人材,プロジェクト,PMO,IT,紹介,高額' }

      it_behaves_like 'メタタグの検証'
    end

    context '検索条件ありの場合' do
      let(:description) { 'フリーランスのコンサルタントやプロ人材向けのプロジェクト管理をするPM・PMO案件一覧。フリーランスで活躍する方に、PMO,PM,プロジェクトサポートなどのコンサル案件や高額報酬プロジェクトをご紹介。' }
      let(:keywords) { 'PM,PMO,プロジェクト管理,コンサルタント,案件,フリーランス,求人,人材,プロジェクト' }
      let(:category_param) { CGI.escape('プロジェクト管理') }

      context '検索ワードが空のパターン' do
        let(:search_params) { "keyword=&categories[]=#{category_param}&work_locations[]=kita_kanto&compensation_ids[]=" }
        let(:title) { 'プロジェクト管理をするPM・PMOの案件紹介' }

        it_behaves_like 'メタタグの検証'
      end

      context '検索ワードが１つのパターン' do
        let(:search_params) { "keyword=aaa&categories[]=#{category_param}&work_locations[]=kita_kanto&compensation_ids[]=" }
        let(:title) { '(test) aaa のコンサル案件・人材募集' }

        it_behaves_like 'メタタグの検証'
      end

      context '検索ワードが２つ以上のパターン' do
        let(:search_params) { "keyword=aaa+bbb&categories[]=#{category_param}&work_locations[]=kita_kanto&compensation_ids[]=" }
        let(:title) { '(test) aaa,bbb のコンサル案件・人材募集' }

        it_behaves_like 'メタタグの検証'
      end
    end
  end

  describe 'GET /project' do
    it do
      is_expected.to eq 200
      expect(doc).to (satisfy { |d| d.find('#categories').has_content?('プロジェクト管理') })
        .and(satisfy { |d| d.find('#work_locations').has_content?('北海道・東北') })
        .and(satisfy { |d| d.find('#compensation_ids').has_content?('〜80万円') })
    end
  end

  describe 'GET /job/:project_id' do
    let(:project) { FactoryBot.create(:project, :with_category, main_category: %w[PM/PMO 新規事業]).decorate }
    let(:project_id) { project.project_id }

    let(:title) { "(test) #{project.project_name} | フリーコンサルタント.jp" }
    let(:description) { project.description }
    let(:keywords) { 'PM/PMO, 新規事業' }

    it_behaves_like 'メタタグの検証'

    describe 'OGP' do
      before do
        send_request
      end

      it do
        expect(doc).to [
          have_selector('meta[property="og:type"][content="article"]', visible: false),
          have_selector('meta[property="og:site_name"][content="フリーコンサルタント.jp"]', visible: false),
          have_selector('meta[property="og:title"]', visible: false) do |tag|
            tag['content'] == project.project_name
          end,
          have_selector('meta[property="og:description"]', visible: false) do |tag|
            tag['content'] == project.description
          end,
          have_selector('meta[property="og:url"]', visible: false) do |tag|
            tag['content'] == project_url(project)
          end,
          have_selector('meta[property="og:image"]', visible: false) do |tag|
            tag['content'] == 'http://www.example.com/assets/images/ogp.png'
          end
        ].inject(:and)
      end
    end

    describe '関連案件' do
      let(:today) { '2020-11-30'.to_date }
      let!(:match_projects) do
        projects = FactoryBot.create_list(:project, 4, experiencecatergory__c: project.experiencecatergory__c)
        projects += FactoryBot.create_list(:project, 2, experiencecatergory__c: project.experiencecatergory__c, created_at: 6.months.ago)
        ProjectDecorator.decorate_collection(projects)
      end
      let!(:not_match_projects) do
        projects = FactoryBot.create_list(:project, 2)
        projects += FactoryBot.create_list(:project, 2, experiencecatergory__c: project.experiencecatergory__c, created_at: 7.months.ago)
        ProjectDecorator.decorate_collection(projects)
      end

      around do |ex|
        travel_to(today) { ex.run }
      end

      it do
        is_expected.to eq 200
        expect(response.body).to [
          *match_projects.map { |pj| include(pj.project_name) },
          *not_match_projects.map { |pj| not_include(pj.project_name) }
        ].inject(:and)
      end
    end

    describe 'ページビュー' do
      let(:fc_user) { FactoryBot.create(:fc_user, :activated) }
      let(:sf_account) { FactoryBot.build_stubbed(:sf_account_fc) }
      let(:sf_contact) { FactoryBot.build_stubbed(:sf_contact, :fc) }

      before do
        allow_any_instance_of(Account).to receive(:to_sobject).and_return(sf_account)
        allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)

        sign_in(fc_user)
      end

      it do
        expect do
          subject
        end.to change { project.reload.impressionist_count }.by(1)
      end

      it do
        is_expected.to eq 200
        expect(Impression.last).to have_attributes(
          user_id: fc_user.id,
          message: 'FcUser'
        )
      end
    end
  end

  describe 'GET /projects/:slug' do
    describe ':new_project_category_meta of Feature Switch' do
      let(:slug) { project_category_metum.slug }
      let!(:project_category_metum) do
        FactoryBot.create(
          :project_category_metum,
          title:       'Sample Title',
          description: 'Sample Description',
          keywords:    'Sample Keyword'
        )
      end

      # TODO: #3440 FeatureSwitch.enableを無くす
      context 'with true' do
        before do
          FeatureSwitch.enable :new_project_category_meta
        end
        let(:title) { "(test) #{project_category_metum.title} | フリーコンサルタント.jp" }
        let(:description) { project_category_metum.description }
        let(:keywords) { project_category_metum.keywords }

        it_behaves_like 'メタタグの検証'
      end

      context 'with false' do
        it { is_expected.to redirect_to(projects_path) }
      end
    end
  end
end
