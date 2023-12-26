# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Project, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:client).class_name('Account').with_foreign_key(:accountid).with_primary_key(:sfid) }
    it { is_expected.to belong_to(:fc_account).class_name('Account').with_foreign_key(:fc__c).with_primary_key(:sfid) }
    it { is_expected.to belong_to(:main_fc_contact).class_name('Contact').with_foreign_key(:fc_gyomusekinin_main_new__c).with_primary_key(:sfid).optional }
    it { is_expected.to belong_to(:sub_fc_contact).class_name('Contact').with_foreign_key(:fc_gyomusekinin_sub_new__c).with_primary_key(:sfid).optional }
    it { is_expected.to belong_to(:main_cl_contact).class_name('Contact').with_foreign_key(:cl_gyomusekinin_main_c__c).with_primary_key(:sfid).optional }
    it { is_expected.to belong_to(:sub_cl_contact).class_name('Contact').with_foreign_key(:cl_gyomusekinin_sub_c__c).with_primary_key(:sfid).optional }
    it { is_expected.to have_many(:entries).class_name('Matching').with_foreign_key(:opportunity__c).with_primary_key(:sfid) }
    it { is_expected.to have_many(:effective_entries).class_name('Matching').with_foreign_key(:opportunity__c).with_primary_key(:sfid) }
    it { is_expected.to have_one(:experience).class_name('Experience').with_foreign_key(:opportunity__c).with_primary_key(:sfid) }
  end

  describe 'scopes' do
    describe '.with_compensations' do
      let!(:project1) { FactoryBot.create(:project, web_reward_min__c: 500_000) }
      let!(:project2) { FactoryBot.create(:project, web_reward_min__c: 1_000_000) }
      let!(:project3) { FactoryBot.create(:project, web_reward_min__c: 300_000) }
      let!(:project4) { FactoryBot.create(:project, web_reward_min__c: 1_500_000) }

      context 'with compensations' do
        it do
          expect(Project.with_compensations([500_000..1_000_000]))
            .to include(project1, project2)
            .and not_include(project3, project4)
        end
      end

      context 'without compensation' do
        it do
          expect(Project.with_compensations(nil)).to include(project1, project2, project3, project4)
        end
      end
    end

    describe '.with_experience_categories' do
      let!(:project1) { FactoryBot.create(:project, experiencecatergory__c: [Project::ExperienceCategory.pluck(:value)[0]]) }
      let!(:project2) { FactoryBot.create(:project, experiencecatergory__c: [Project::ExperienceCategory.pluck(:value)[1]]) }
      let!(:project3) { FactoryBot.create(:project, experiencecatergory__c: Project::ExperienceCategory.pluck(:value).take(2)) }
      let!(:project4) { FactoryBot.create(:project, experiencecatergory__c: [Project::ExperienceCategory.pluck(:value)[2]]) }

      context 'with categories' do
        it do
          expect(Project.with_experience_categories(Project::ExperienceCategory.take(2).pluck(:value)))
            .to include(project1, project2, project3)
            .and not_include(project4)
        end
      end

      context 'without categories' do
        it do
          expect(Project.with_experience_categories([]))
            .to include(project1, project2, project3, project4)
        end
      end
    end

    describe '.sort_compensation' do
      let!(:higher_project) { FactoryBot.create(:project, web_reward_min__c: 100) }
      let!(:lower_project) { FactoryBot.create(:project, web_reward_min__c: 50) }
      let!(:nulled_project) { FactoryBot.create(:project, web_reward_min__c: nil) }

      it do
        expect(Project.sort_compensation).to eq [higher_project, lower_project, nulled_project]
      end
    end

    describe '.latest_order' do
      let!(:project_a) { FactoryBot.create(:project, web_publishdatetime__c: '2020-11-29 10:00') }
      let!(:project_b) { FactoryBot.create(:project, web_publishdatetime__c: '2020-11-30 09:00') }
      let!(:project_c) { FactoryBot.create(:project, web_publishdatetime__c: nil) }

      it do
        expect(Project.latest_order).to eq [project_b, project_a, project_c]
      end
    end

    describe '.new_arrival' do
      let!(:project_a) { FactoryBot.create(:project, created_at: '2020-10-15 09:00', web_publishdatetime__c: '2020-10-15 09:00') }
      let!(:project_b) { FactoryBot.create(:project, created_at: '2020-11-29 10:00', web_publishdatetime__c: '2020-11-29 10:00') }
      let!(:project_c) { FactoryBot.create(:project, created_at: '2020-11-30 09:00', web_publishdatetime__c: '2020-11-30 09:00') }
      let(:today) { '2020-12-01'.to_date }

      around do |ex|
        travel_to(today) { ex.run }
      end

      it do
        expect(Project.new_arrival).to eq [project_c, project_b]
      end
    end

    describe '.within_half_year' do
      let!(:project_a) { FactoryBot.create(:project, created_at: '2020-05-31 12:59', web_publishdatetime__c: '2020-05-31 12:59') }
      let!(:project_b) { FactoryBot.create(:project, created_at: '2020-06-01 00:00', web_publishdatetime__c: '2020-06-01 00:00') }
      let!(:project_c) { FactoryBot.create(:project, created_at: '2020-06-01 16:00', web_publishdatetime__c: '2020-06-01 16:00') }
      let(:today) { '2020-12-01'.to_date }

      around do |ex|
        travel_to(today) { ex.run }
      end

      it do
        expect(Project.within_half_year).to eq([project_c, project_b])
      end
    end

    describe '.featured_order' do
      let!(:pj_a) { FactoryBot.create(:project, :with_impressions, impression_count: 2, web_publishdatetime__c: 2.days.ago) }
      let!(:pj_b) { FactoryBot.create(:project, :with_impressions, impression_count: 2, web_publishdatetime__c: 1.day.ago) }
      let!(:pj_c) { FactoryBot.create(:project, :with_impressions, impression_datetime: 2.days.ago, web_publishdatetime__c: Time.current) }
      let!(:pj_d) { FactoryBot.create(:project, :with_impressions, impression_count: 5) }
      let!(:pj_e) { FactoryBot.create(:project, web_publishdatetime__c: 1.week.ago) }
      let!(:pj_f) { FactoryBot.create(:project, web_publishdatetime__c: 1.hour.ago) }

      subject { described_class.featured_order }

      before { ProjectDailyPageView.refresh }

      it do
        is_expected.to eq [pj_d, pj_b, pj_a, pj_c, pj_f, pj_e]
      end
    end

    describe '.with_main_category' do
      named_let!(:pj_a) { FactoryBot.create(:project, main_category: ['プロジェクト管理']) }
      named_let!(:pj_b) { FactoryBot.create(:project, main_category: ['プロジェクト管理'], sub_category: ['PM']) }
      named_let!(:pj_c) { FactoryBot.create(:project, main_category: ['プロジェクト管理'], sub_category: ['PMO']) }
      named_let!(:pj_d) { FactoryBot.create(:project, main_category: ['業務改善(BPR/RPA/BPO)']) }
      named_let!(:pj_e) { FactoryBot.create(:project, main_category: ['業務改善(BPR/RPA/BPO)'], sub_category: ['その他（業務改善）']) }

      subject { described_class.with_main_category(main_category) }

      context 'main_category is a plain text' do
        let(:main_category) { 'プロジェクト管理' }

        it do
          is_expected.to eq [pj_a, pj_b, pj_c]
        end
      end

      context 'main_category is a meta character' do
        let(:main_category) { '業務改善(BPR/RPA/BPO)' }

        it do
          is_expected.to eq [pj_d, pj_e]
        end
      end
    end

    describe '.with_sub_category' do
      named_let!(:pj_a) { FactoryBot.create(:project, main_category: ['プロジェクト管理']) }
      named_let!(:pj_b) { FactoryBot.create(:project, main_category: ['プロジェクト管理'], sub_category: ['PM']) }
      named_let!(:pj_c) { FactoryBot.create(:project, main_category: ['プロジェクト管理'], sub_category: ['PMO']) }
      named_let!(:pj_d) { FactoryBot.create(:project, main_category: ['業務改善(BPR/RPA/BPO)']) }
      named_let!(:pj_e) { FactoryBot.create(:project, main_category: ['業務改善(BPR/RPA/BPO)'], sub_category: ['その他（業務改善）']) }

      subject { described_class.with_sub_category(sub_category) }

      context 'sub_category is a plain text' do
        let(:sub_category) { 'PM' }

        it do
          is_expected.to eq [pj_b]
        end
      end

      context 'main_category is a meta character' do
        let(:sub_category) { 'その他（業務改善）' }

        it do
          is_expected.to eq [pj_e]
        end
      end
    end
  end

  describe '#manager?' do
    let!(:project) { FactoryBot.build_stubbed(:project, main_fc_contact:, sub_fc_contact:) }
    let(:account) { FactoryBot.build_stubbed(:account) }
    let(:main_fc_contact) { FactoryBot.build_stubbed(:contact, :fc, account:) }
    let(:sub_fc_contact) { FactoryBot.build_stubbed(:contact, :fc, account:) }

    context 'when user is main fc' do
      named_let(:user) { FactoryBot.build_stubbed(:fc_user, contact: main_fc_contact) }

      it do
        expect(project).to be_manager(user)
      end
    end

    context 'when user is sub fc' do
      named_let(:user) { FactoryBot.build_stubbed(:fc_user, contact: sub_fc_contact) }

      it do
        expect(project).to be_manager(user)
      end
    end

    context 'when user is not main or sub fc' do
      let(:third_contact) { FactoryBot.build_stubbed(:contact, :fc, account:) }
      named_let(:user) { FactoryBot.build_stubbed(:fc_user, contact: third_contact) }

      it do
        expect(project).to_not be_manager(user)
      end
    end
  end

  describe '#entry_exists?' do
    let!(:project) { FactoryBot.create(:project, :with_publish_datetime) }
    let!(:fc_user) { FactoryBot.create(:fc_user, :activated) }
    let!(:matching) { FactoryBot.create(:matching, account: fc_user.account, project:, matching_status__c: matching_status, root__c: root) }

    subject { project.entry_exists?(fc_user) }

    using RSpec::Parameterized::TableSyntax

    # rubocop:disable Layout/ExtraSpacing, Layout/SpaceAroundOperators
    where(:root, :matching_status, :result) do
      '自己推薦(FCWeb)' | '候補'                                | true
      '自己推薦(FCWeb)' | 'エントリー対象'                      | true
      '自己推薦(FCWeb)' | 'エントリー打診済'                    | true
      '自己推薦(FCWeb)' | 'FC辞退(CL挨拶前)'                    | true
      '自己推薦(FCWeb)' | 'エントリー対象外'                    | true
      '自己推薦(FCWeb)' | 'レジュメ提出済'                      | true
      '自己推薦(FCWeb)' | 'クライアントNG(レジュメ提出後)'      | true
      '自己推薦(FCWeb)' | 'クライアント挨拶調整済'              | true
      '自己推薦(FCWeb)' | 'FC辞退手続中'                        | true
      '自己推薦(FCWeb)' | 'FC辞退(CL挨拶後)'                    | true
      '自己推薦(FCWeb)' | 'クライアントNG(挨拶実施後)'          | true
      '自己推薦(FCWeb)' | 'オファー連絡済'                      | true
      '自己推薦(FCWeb)' | 'WIN(マッチング)'                     | true
      '自己推薦(FCWeb)' | 'LOST(案件クローズ等)'                | false
      '自己推薦(FCWeb)' | '候補FC辞退'                          | false
      '自己推薦(FCWeb)' | 'LOST_候補'                           | true
      '自己推薦(FCWeb)' | 'LOST_エントリー対象'                 | true
      '自己推薦(FCWeb)' | 'LOST_エントリー打診済'               | true
      '自己推薦(FCWeb)' | 'LOST_FC辞退(CL挨拶前)'               | true
      '自己推薦(FCWeb)' | 'LOST_エントリー対象外'               | true
      '自己推薦(FCWeb)' | 'LOST_レジュメ提出済'                 | true
      '自己推薦(FCWeb)' | 'LOST_クライアントNG(レジュメ提出後)' | true
      '自己推薦(FCWeb)' | 'LOST_クライアント挨拶調整済'         | true
      '自己推薦(FCWeb)' | 'LOST_FC辞退手続中'                   | true
      '自己推薦(FCWeb)' | 'LOST_FC辞退(CL挨拶後)'               | true
      '自己推薦(FCWeb)' | 'LOST_クライアントNG(挨拶実施後)'     | true
      '自己推薦(FCWeb)' | 'LOST_オファー連絡済'                 | true
      '自己推薦(FCWeb)' | 'クローズ_重複'                       | false
      '営業推薦'        | '候補'                                | false
      '営業推薦'        | 'エントリー対象'                      | false
      '営業推薦'        | 'エントリー打診済'                    | false
      '営業推薦'        | 'FC辞退(CL挨拶前)'                    | false
      '営業推薦'        | 'エントリー対象外'                    | false
      '営業推薦'        | 'レジュメ提出済'                      | true
      '営業推薦'        | 'クライアントNG(レジュメ提出後)'      | true
      '営業推薦'        | 'クライアント挨拶調整済'              | true
      '営業推薦'        | 'FC辞退手続中'                        | true
      '営業推薦'        | 'FC辞退(CL挨拶後)'                    | true
      '営業推薦'        | 'クライアントNG(挨拶実施後)'          | true
      '営業推薦'        | 'オファー連絡済'                      | true
      '営業推薦'        | 'WIN(マッチング)'                     | true
      '営業推薦'        | 'LOST(案件クローズ等)'                | false
      '営業推薦'        | '候補FC辞退'                          | false
      '営業推薦'        | 'LOST_候補'                           | false
      '営業推薦'        | 'LOST_エントリー対象'                 | false
      '営業推薦'        | 'LOST_エントリー打診済'               | false
      '営業推薦'        | 'LOST_FC辞退(CL挨拶前)'               | false
      '営業推薦'        | 'LOST_エントリー対象外'               | false
      '営業推薦'        | 'LOST_レジュメ提出済'                 | true
      '営業推薦'        | 'LOST_クライアントNG(レジュメ提出後)' | true
      '営業推薦'        | 'LOST_クライアント挨拶調整済'         | true
      '営業推薦'        | 'LOST_FC辞退手続中'                   | true
      '営業推薦'        | 'LOST_FC辞退(CL挨拶後)'               | true
      '営業推薦'        | 'LOST_クライアントNG(挨拶実施後)'     | true
      '営業推薦'        | 'LOST_オファー連絡済'                 | true
      '営業推薦'        | 'クローズ_重複'                       | false
    end
    # rubocop:enable Layout/ExtraSpacing, Layout/SpaceAroundOperators

    with_them do
      it do
        is_expected.to eq result
      end
    end
  end

  describe '#entry_stopped?' do
    let!(:project) { FactoryBot.create(:project) }
    let!(:fc_user) { FactoryBot.create(:fc_user, :activated) }
    let!(:matching) { FactoryBot.create(:matching, account: fc_user.account, project:, matching_status__c: matching_status, root__c: root) }

    subject { project.entry_stopped?(fc_user) }

    using RSpec::Parameterized::TableSyntax

    # rubocop:disable Layout/ExtraSpacing, Layout/SpaceAroundOperators
    where(:matching_status, :root, :result) do
      '候補'                                | :recommend_sales       | false
      'エントリー対象'                      | :recommend_sales       | false
      'エントリー打診済'                    | :recommend_sales       | false
      'FC辞退(CL挨拶前)'                    | :recommend_sales       | false
      'レジュメ提出済'                      | :recommend_sales       | false
      'クライアント挨拶調整済'              | :recommend_sales       | false
      'FC辞退(CL挨拶後)'                    | :recommend_sales       | false
      'オファー連絡済'                      | :recommend_sales       | false
      'WIN(マッチング)'                     | :recommend_sales       | false
      'エントリー対象外'                    | :recommend_sales       | false
      'クライアントNG(レジュメ提出後)'      | :recommend_sales       | false
      'クライアントNG(挨拶実施後)'          | :recommend_sales       | false
      'LOST(案件クローズ等)'                | :recommend_sales       | false
      'LOST_候補'                           | :recommend_sales       | true
      'LOST_エントリー対象'                 | :recommend_sales       | true
      'LOST_エントリー打診済'               | :recommend_sales       | true
      'LOST_FC辞退(CL挨拶前)'               | :recommend_sales       | true
      'LOST_エントリー対象外'               | :recommend_sales       | true
      'LOST_レジュメ提出済'                 | :recommend_sales       | true
      'LOST_クライアントNG(レジュメ提出後)' | :recommend_sales       | true
      '候補FC辞退'                          | :recommend_sales       | false
      'FC辞退手続中'                        | :recommend_sales       | false
      'FC辞退手続中'                        | :recommend_colabo      | false
      'FC辞退手続中'                        | :self_recommend_direct | false
      'FC辞退手続中'                        | :self_recommend_fcweb  | false
    end
    # rubocop:enable Layout/ExtraSpacing, Layout/SpaceAroundOperators

    with_them do
      it do
        is_expected.to eq result
      end
    end
  end

  describe '.location_to_prefectures' do
    using RSpec::Parameterized::TableSyntax

    subject { described_class.location_to_prefectures(location) }

    where(:location, :prefectures) do
      'hokkaido'      | %w[北海道 青森県 岩手県 宮城県 秋田県 山形県 福島県]
      'kita_kanto'    | %w[茨城県 栃木県 群馬県]
      'tokyo_23wards' | %w[東京都23区内]
      'tokyo_others'  | %w[東京都23区外]
      'capital_area'  | %w[埼玉県 千葉県 神奈川県]
      'chubu'         | %w[新潟県 富山県 石川県 福井県 山梨県 長野県 岐阜県 静岡県 愛知県]
      'kinki'         | %w[大阪府 京都府 兵庫県 滋賀県 奈良県 三重県 和歌山県]
      'chugoku'       | %w[鳥取県 島根県 岡山県 広島県 山口県]
      'shikoku'       | %w[徳島県 香川県 愛媛県 高知県]
      'kyushu'        | %w[福岡県 佐賀県 長崎県 熊本県 大分県 宮崎県 鹿児島県 沖縄県]
      'japan'         | %w[日本全国]
      'overseas'      | %w[海外]
    end

    with_them do
      it do
        is_expected.to eq prefectures
      end
    end
  end
end

# == Schema Information
#
# Table name: salesforce.opportunity
#
#  id                                :integer          not null, primary key
#  _hc_err                           :text
#  _hc_lastop                        :string(32)
#  accountid                         :string(18)
#  ankenid2__c                       :string(255)
#  cl_gyomusekinin_main_c__c         :string(18)
#  cl_gyomusekinin_sub_c__c          :string(18)
#  createddate                       :datetime
#  experiencecatergory__c            :string(4099)
#  experiencesubcatergory__c         :string(4099)
#  fc__c                             :string(18)
#  fc_gyomusekinin_main_new__c       :string(18)
#  fc_gyomusekinin_sub_new__c        :string(18)
#  fcweb_pic__c                      :string(255)
#  gyomu_tytle__c                    :string(255)
#  isclosedwebreception__c           :boolean
#  isdeleted                         :boolean
#  jobposting_isactive__c            :boolean
#  jobposting_joblocationtype__c     :boolean
#  kaishiyoteibi_input__c            :date
#  lastmodifieddate                  :datetime
#  mws_gyomusekinin_main_c__c        :string(18)
#  mws_gyomusekinin_sub_c__c         :string(18)
#  name                              :string(120)
#  owner__user_name__c               :string(255)
#  ownerid                           :string(18)
#  recordtypeid                      :string(18)
#  reward__c                         :float
#  sfid                              :string(18)
#  shouryuu__c                       :string(255)
#  systemmodstamp                    :datetime
#  type                              :string(255)
#  web_background__c                 :string(500)
#  web_clientname__c                 :string(255)
#  web_comment__c                    :string(500)
#  web_expiredatetime__c             :datetime
#  web_human_resource_main__c        :string(500)
#  web_human_resource_sub__c         :string(500)
#  web_joboutline__c                 :string(500)
#  web_kado_max__c                   :string(255)
#  web_kado_min__c                   :string(255)
#  web_kado_note__c                  :string(128)
#  web_openflag__c                   :boolean
#  web_owner_pictureflag__c          :boolean
#  web_period__c                     :string(128)
#  web_period_from__c                :date
#  web_period_to__c                  :date
#  web_photo__c                      :string(255)
#  web_picture__c                    :string(1300)
#  web_place_note__c                 :string(128)
#  web_projectname__c                :string(255)
#  web_projectoutline__c             :string(2000)
#  web_publishdatetime__c            :datetime
#  web_reward_max__c                 :float
#  web_reward_min__c                 :float
#  web_reward_note__c                :string(128)
#  web_schema_basesalary_max__c      :float
#  web_schema_basesalary_min__c      :float
#  web_schema_description__c         :string(1500)
#  web_schema_emptype__c             :string(255)
#  web_schema_region__c              :string(255)
#  web_schema_title__c               :string(255)
#  web_schemaquantitativeunittext__c :string(255)
#  web_status__c                     :string(255)
#  web_workenvironment__c            :string(255)
#  web_worksection__c                :string(255)
#  work_options__c                   :string(4099)
#  work_prefectures__c               :string(4099)
#
# Indexes
#
#  hc_idx_opportunity_accountid                  (accountid)
#  hc_idx_opportunity_experiencecatergory__c     (experiencecatergory__c)
#  hc_idx_opportunity_experiencesubcatergory__c  (experiencesubcatergory__c)
#  hc_idx_opportunity_isclosedwebreception__c    (isclosedwebreception__c)
#  hc_idx_opportunity_lastmodifieddate           (lastmodifieddate)
#  hc_idx_opportunity_ownerid                    (ownerid)
#  hc_idx_opportunity_systemmodstamp             (systemmodstamp)
#  hc_idx_opportunity_web_openflag__c            (web_openflag__c)
#  hc_idx_opportunity_web_reward_min__c          (web_reward_min__c)
#  hcu_idx_opportunity_ankenid2__c               (ankenid2__c) UNIQUE
#  hcu_idx_opportunity_sfid                      (sfid) UNIQUE
#
