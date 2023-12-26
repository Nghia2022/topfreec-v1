# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProjectSearchQuery, type: :query do
  let(:fc_user) { FactoryBot.create(:fc_user, :activated) }
  let(:relation) { Project.all }
  let(:user) { fc_user }
  let(:query) { ProjectSearchQuery.new(relation:, form:, user:) }
  let(:sort_type) { nil }
  let(:recruiting) { false }
  let(:form) do
    instance_double('form', form_attributes)
  end
  let(:form_attributes) do
    {
      keyword:             'keyword',
      compensation_ranges: [1..10],
      categories:,
      work_locations:      [DesiredCondition.work_location1.values.sample],
      work_options:        [Project::WorkOption.pluck(:value).sample],
      occupancy_rate_mins: [Project::OccupancyRateMin.pluck(:value).sample],
      occupancy_rate_maxs: [Project::OccupancyRateMax.pluck(:value).sample],
      period_from:,
      period_to:,
      sort:                sort_type,
      recruiting:
    }
  end
  let(:categories) { [Project::ExperienceCategory.pick(:value)] }

  let(:work_prefectures) { [Project.location_to_prefectures(form.work_locations.first).first] }
  let(:period_from) { '2021-11-01' }
  let(:period_to) { '2021-11-30' }

  named_let!(:project_unmatched_all) { FactoryBot.create(:project, :with_publish_datetime, work_prefectures__c: []) }
  named_let!(:project_matched_all) do
    FactoryBot.create(
      :project,
      :with_publish_datetime,
      web_projectname__c:     form.keyword,
      work_prefectures__c:    work_prefectures,
      work_options__c:        form.work_options.first,
      web_kado_min__c:        form.occupancy_rate_mins.first,
      web_kado_max__c:        form.occupancy_rate_maxs.first,
      web_period_from__c:     period_from,
      web_period_to__c:       period_to,
      experiencecatergory__c: [Project::ExperienceCategory.pick(:value)],
      web_reward_min__c:      form.compensation_ranges.first.first
    )
  end

  named_let!(:project_largest_compensation) do
    FactoryBot.create(
      :project,
      :with_publish_datetime,
      web_projectname__c:     form.keyword,
      work_prefectures__c:    work_prefectures,
      work_options__c:        form.work_options.first,
      web_kado_min__c:        form.occupancy_rate_mins.first,
      web_kado_max__c:        form.occupancy_rate_maxs.first,
      web_period_from__c:     period_from,
      web_period_to__c:       period_to,
      experiencecatergory__c: [Project::ExperienceCategory.pick(:value)],
      web_reward_min__c:      form.compensation_ranges.first.last
    )
  end

  named_let!(:project_last_createddate) do
    FactoryBot.create(
      :project,
      :with_publish_datetime,
      web_projectname__c:     form.keyword,
      work_prefectures__c:    work_prefectures,
      work_options__c:        form.work_options.first,
      web_kado_min__c:        form.occupancy_rate_mins.first,
      web_kado_max__c:        form.occupancy_rate_maxs.first,
      web_period_from__c:     period_from,
      web_period_to__c:       period_to,
      experiencecatergory__c: [Project::ExperienceCategory.pick(:value)],
      web_reward_min__c:      form.compensation_ranges.first.first,
      web_publishdatetime__c: Time.current + 10
    )
  end

  named_let!(:project_matched_keyword) { FactoryBot.create(:project, :with_publish_datetime, web_projectname__c: form.keyword) }
  named_let!(:project_matched_work_location) { FactoryBot.create(:project, :with_publish_datetime, work_prefectures__c: work_prefectures) }
  named_let!(:project_matched_work_option) { FactoryBot.create(:project, :with_publish_datetime, work_options__c: form.work_options.first) }
  named_let!(:project_matched_occupancy_rate_min) { FactoryBot.create(:project, :with_publish_datetime, web_kado_min__c: form.occupancy_rate_mins.first) }
  named_let!(:project_matched_occupancy_rate_max) { FactoryBot.create(:project, :with_publish_datetime, web_kado_max__c: form.occupancy_rate_maxs.first) }
  named_let!(:project_matched_period_from) { FactoryBot.create(:project, :with_publish_datetime, web_period_from__c: period_from) }
  named_let!(:project_matched_period_to) { FactoryBot.create(:project, :with_publish_datetime, web_period_to__c: period_to) }
  named_let!(:project_matched_categories) { FactoryBot.create(:project, :with_publish_datetime, experiencecatergory__c: categories) }
  named_let!(:project_matched_compensation) { FactoryBot.create(:project, :with_publish_datetime, web_reward_min__c: form.compensation_ranges.first.first) }

  describe '#call' do
    subject { query.call }

    context 'when search by all conditions' do
      it do
        is_expected.to include(project_matched_all)
          .and not_include(project_unmatched_all)
          .and not_include(
            project_matched_keyword, project_matched_work_location, project_matched_categories, project_matched_compensation,
            project_matched_work_option, project_matched_occupancy_rate_min, project_matched_occupancy_rate_max,
            project_matched_period_from, project_matched_period_to
          )
      end
    end

    context 'when search by occupancy_rate_min' do
      let(:mins) { Project::OccupancyRateMin.pluck(:value) }
      let(:query) { ProjectSearchQuery.new(relation:, form: occupancy_rate_mins_only_form, user: fc_user) }
      let(:occupancy_rate_mins_only_form) do
        instance_double('form', {
                          keyword:             nil,
                          compensation_ranges: [],
                          categories:          [],
                          work_locations:      [],
                          work_options:        [],
                          occupancy_rate_mins: [mins[5]],
                          occupancy_rate_maxs: [],
                          period_from:         nil,
                          period_to:           nil,
                          sort:                nil,
                          recruiting:          nil
                        })
      end

      named_let!(:project_less) { FactoryBot.create(:project, :with_publish_datetime, web_kado_min__c: mins[4]) }
      named_let!(:project_equal) { FactoryBot.create(:project, :with_publish_datetime, web_kado_min__c: mins[5]) }
      named_let!(:project_greater) { FactoryBot.create(:project, :with_publish_datetime, web_kado_min__c: mins[6]) }

      it do
        is_expected.to include(project_equal)
          .and not_include(project_less)
          .and include(project_greater)
      end
    end

    context 'when search by occupancy_rate_max' do
      let(:maxs) { Project::OccupancyRateMax.pluck(:value) }
      let(:query) { ProjectSearchQuery.new(relation:, form: occupancy_rate_maxs_only_form, user: fc_user) }
      let(:occupancy_rate_maxs_only_form) do
        instance_double('form', {
                          keyword:             nil,
                          compensation_ranges: [],
                          categories:          [],
                          work_locations:      [],
                          work_options:        [],
                          occupancy_rate_mins: [],
                          occupancy_rate_maxs: [maxs[5]],
                          period_from:         nil,
                          period_to:           nil,
                          sort:                nil,
                          recruiting:          nil
                        })
      end

      named_let!(:project_less) { FactoryBot.create(:project, :with_publish_datetime, web_kado_max__c: maxs[4]) }
      named_let!(:project_equal) { FactoryBot.create(:project, :with_publish_datetime, web_kado_max__c: maxs[5]) }
      named_let!(:project_greater) { FactoryBot.create(:project, :with_publish_datetime, web_kado_max__c: maxs[6]) }

      it do
        is_expected.to include(project_equal)
          .and include(project_less)
          .and not_include(project_greater)
      end
    end

    context 'when filter by closed' do
      named_let!(:project_closed) do
        project_matched_all.dup.tap do |project|
          project.update!(
            sfid:                    FactoryBot.generate(:sfid),
            ankenid2__c:             Faker::Number.number,
            isclosedwebreception__c: true
          )
        end
      end

      context 'when recruiting flag is false' do
        it do
          is_expected.to include(project_closed)
            .and include(project_matched_all)
        end
      end

      context 'with recruiting flag is true' do
        let(:recruiting) { true }

        it do
          is_expected.to not_include(project_closed)
            .and include(project_matched_all)
        end
      end
    end

    context 'when filter with user entries' do
      context 'when filter by stopped' do
        named_let!(:project_stopped) do
          project_matched_all.dup.tap do |project|
            project.update!(
              sfid:        FactoryBot.generate(:sfid),
              ankenid2__c: Faker::Number.number
            )
          end
        end
        let!(:matching) { FactoryBot.create(:matching, account: fc_user.account, project: project_stopped, root__c: :recommend_sales, matching_status__c: :lost_candidate) }

        context 'when recruiting flag is false' do
          it do
            is_expected.to include(project_stopped)
              .and include(project_matched_all)
          end
        end

        context 'with recruiting flag is true' do
          let(:recruiting) { true }

          it do
            is_expected.to not_include(project_stopped)
              .and include(project_matched_all)
          end
        end
      end

      context 'when filter by entered' do
        named_let!(:project_entered) do
          project_matched_all.dup.tap do |project|
            project.update!(
              sfid:                   FactoryBot.generate(:sfid),
              ankenid2__c:            Faker::Number.number,
              web_publishdatetime__c: Time.current
            )
          end
        end
        let!(:matching) { FactoryBot.create(:matching, account: fc_user.account, project: project_entered, matching_status__c: :candidate, root__c: :self_recommend_fcweb) }

        context 'when user is nil' do
          let(:user) { nil }

          it do
            is_expected.to include(project_entered)
              .and include(project_matched_all)
          end
        end

        context 'when user is not nil' do
          it do
            is_expected.to not_include(project_entered)
              .and include(project_matched_all)
          end
        end
      end
    end

    context 'when sort by compensation' do
      let(:sort_type) { 'compensation' }
      it do
        expect(subject.first).to eq(project_largest_compensation)
      end

      context 'compensation nil exists' do
        let(:compensation_range_nil_form) { instance_double('form', form_attributes.merge(keyword: 'keyword', sort: sort_type, compensation_ranges: nil)) }
        let(:query) { ProjectSearchQuery.new(relation:, form: compensation_range_nil_form, user: fc_user) }

        it do
          expect(subject.first).to eq(project_largest_compensation)
        end
      end
    end

    context 'when sort by createddate' do
      let(:sort_type) { 'createddate' }
      it do
        expect(subject.first).to eq(project_last_createddate)
      end
    end

    context 'sort_type nil' do
      it do
        expect(subject.first).to eq(project_last_createddate)
      end
    end
  end

  describe '#order_scope' do
    subject { query.send(:order_scope) }

    context 'when sort == nil' do
      let(:sort_type) { nil }

      it do
        expect(subject.first).to eq(project_last_createddate)
      end
    end

    context 'when sort == createddate' do
      let(:sort_type) { 'createddate' }

      it do
        expect(subject.first).to eq(project_last_createddate)
      end
    end

    context 'when sort == compensation' do
      let(:sort_type) { 'compensation' }

      it do
        expect(subject.first).to eq(project_largest_compensation)
      end
    end
  end

  describe '#occupancy_rate_mins' do
    using RSpec::Parameterized::TableSyntax

    # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
    where(:min, :result) do
      90  | [nil, 90, 100]
      nil | nil
    end
    # rubocop:enable Lint/BinaryOperatorWithIdenticalOperands

    with_them do
      let(:query) { ProjectSearchQuery.new(relation:, form: occupancy_rate_form, user: fc_user) }
      let(:occupancy_rate_form) do
        instance_double('form', {
                          **form_attributes,
                          occupancy_rate_mins: [min]
                        })
      end

      subject { query.send(:occupancy_rate_mins) }

      it { is_expected.to eq(result) }
    end
  end

  describe '#occupancy_rate_maxs' do
    using RSpec::Parameterized::TableSyntax

    # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
    where(:max, :result) do
      20 | [nil, 10, 20]
      nil | nil
    end
    # rubocop:enable Lint/BinaryOperatorWithIdenticalOperands

    with_them do
      let(:query) { ProjectSearchQuery.new(relation:, form: occupancy_rate_form, user: fc_user) }
      let(:occupancy_rate_form) do
        instance_double('form', {
                          **form_attributes,
                          occupancy_rate_maxs: [max]
                        })
      end

      subject { query.send(:occupancy_rate_maxs) }

      it { is_expected.to eq(result) }
    end
  end
end
