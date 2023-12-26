# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProjectCategoryMetum, type: :model do
  let!(:project_category_metum) { FactoryBot.create(:project_category_metum) }

  describe 'associations' do
    it { should belong_to(:work_category).with_foreign_key(:work_category_main).with_primary_key(:main_category) }
    it { should belong_to(:project_experience_category).with_foreign_key(:work_category_main).with_primary_key(:value) }
  end

  describe 'validations' do
    it { is_expected.to validate_length_of(:title).is_at_most(described_class::TITLE_LIMIT) }
    it { is_expected.to validate_length_of(:description).is_at_most(MetaTags.config.description_limit) }
    it { is_expected.to validate_presence_of(:slug) }
    it { is_expected.to validate_uniqueness_of(:slug) }

    describe '#work_category_main' do
      it { is_expected.to validate_presence_of(:work_category_main) }
      it { is_expected.to validate_inclusion_of(:work_category_main).in_array(WorkCategory.pluck(:main_category)) }
    end

    describe '#work_category_sub' do
      it { is_expected.to validate_inclusion_of(:work_category_sub).in_array(WorkCategory.pluck(:sub_category).flatten) }
      it { is_expected.to allow_value(nil).for(:work_category_sub) }
    end
  end

  describe '#projects' do
    subject { project_category_metum.projects }

    let!(:work_categories) { WorkCategory.all.sample(3) }
    let!(:target_work_categories) do
      work_categories.map do |work_category|
        {
          main_category: work_category.main_category,
          sub_category:  work_category.sub_category.shuffle!.shift
        }
      end
    end
    let!(:work_categories_with_another_sub_category) do
      work_categories.map do |work_category|
        {
          main_category: work_category.main_category,
          sub_category:  work_category.sub_category.shuffle!.shift
        }
      end
    end
    let!(:work_categories_with_another_main_category) { WorkCategory.where.not(id: work_categories.pluck(:id)).sample(3) }

    named_let!(:project) do
      FactoryBot.create(
        :project,
        :with_category,
        main_category: target_work_categories.pluck(:main_category),
        sub_category:  target_work_categories.pluck(:sub_category)
      )
    end
    named_let!(:project_with_another_sub_category) do
      FactoryBot.create(
        :project,
        :with_category,
        main_category: work_categories_with_another_sub_category.pluck(:main_category),
        sub_category:  work_categories_with_another_sub_category.pluck(:sub_category)
      )
    end
    named_let!(:project_with_another_main_category) { FactoryBot.create(:project, :with_category, work_categories: work_categories_with_another_main_category) }

    context 'when having only main_category' do
      let(:project_category_metum) { FactoryBot.build(:project_category_metum, work_category_main: target_work_categories.first[:main_category]) }

      it 'get all projects of the same main_categories' do
        is_expected.to include(project, project_with_another_sub_category)
      end

      it 'do not get projects of the different main_categories' do
        is_expected.to_not include(project_with_another_main_category)
      end
    end

    context 'when having main_category and sub_categories' do
      let(:project_category_metum) { FactoryBot.build(:project_category_metum, work_category_main: target_work_categories.first[:main_category], work_category_sub: target_work_categories.first[:sub_category]) }

      it 'get projects of the same sub_categories' do
        is_expected.to include(project)
      end

      it 'do not get projects of the different sub_categories and main_categories' do
        is_expected.to_not include(project_with_another_sub_category, project_with_another_main_category)
      end
    end

    context 'when having similar name of sub_categories' do
      let(:project_category_metum) { FactoryBot.build(:project_category_metum, work_category_main: 'プロジェクト管理', work_category_sub: 'PM') }
      let!(:project) { FactoryBot.create(:project, :with_category, main_category: %w[プロジェクト管理], sub_category: %w[PM]) }
      let!(:another_project) { FactoryBot.create(:project, :with_category, main_category: %w[プロジェクト管理], sub_category: %w[PMO]) }

      it 'get only the project' do
        is_expected.to include(project)
      end

      it 'do not get another project' do
        is_expected.to_not include(another_project)
      end
    end
  end

  describe '.fetch_by_or_null' do
    subject { described_class.fetch_by_or_null(target_attributes) }

    context 'when a record exists' do
      let!(:project_category_metum) { FactoryBot.create(:project_category_metum, slug: 'project-management', work_category_main: 'プロジェクト管理') }

      context 'with :slug' do
        let(:target_attributes) { { slug: 'project-management' } }
        it { is_expected.to eq project_category_metum }
      end

      context 'with :work_category_main' do
        let(:target_attributes) { { work_category_main: 'プロジェクト管理' } }
        it { is_expected.to eq project_category_metum }
      end
    end

    context 'when a record does not exist' do
      let(:target_attributes) { { slug: 'test' } }
      it { expect(subject.title).to eq I18n.t(:title, scope: ProjectCategoryMetum::I18N_SCOPE) }
      it { expect(subject.description).to eq I18n.t(:description, scope: ProjectCategoryMetum::I18N_SCOPE) }
      it { expect(subject.keywords).to eq I18n.t(:keywords, scope: ProjectCategoryMetum::I18N_SCOPE) }
    end
  end

  describe '#category_name' do
    subject { project_category_metum.category_name }

    context 'when main_category' do
      let!(:project_category_metum) { FactoryBot.create(:project_category_metum, work_category_main: 'プロジェクト管理', work_category_sub: '') }
      it { is_expected.to eq 'プロジェクト管理' }
    end

    context 'when sub_category' do
      let!(:project_category_metum) { FactoryBot.create(:project_category_metum, work_category_main: 'プロジェクト管理', work_category_sub: 'PM') }
      it { is_expected.to eq 'PM' }
    end
  end
end

# == Schema Information
#
# Table name: project_category_meta
#
#  id                 :bigint           not null, primary key
#  description        :text
#  keywords           :string
#  slug               :string           not null
#  title              :string
#  work_category_main :string           not null
#  work_category_sub  :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_project_category_meta_on_slug  (slug) UNIQUE
#
