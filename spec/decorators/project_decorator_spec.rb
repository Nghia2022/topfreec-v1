# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProjectDecorator do
  subject(:decorated) { described_class.new(model.decorate) }

  describe 'delegations' do
    let(:model) { FactoryBot.build(:project) }

    it { is_expected.to delegate_method(:client_name).to(:client) }
  end

  describe '#project_name' do
    let(:model) { FactoryBot.build(:project, web_projectname__c: 'プロジェクト名').decorate }

    it do
      expect(subject.project_name).to eq model.project_name
    end
  end

  describe '#compensation' do
    let(:model) { FactoryBot.build(:project, reward__c: '1000').decorate }

    it do
      expect(subject.compensation).to eq model.compensation
    end
  end

  describe '#updated_at' do
    let(:model) { FactoryBot.build(:project, updated_at: Time.zone.now) }

    it do
      expect(subject.updated_at).to eq model.updated_at
    end
  end

  describe '#experience_categories' do
    let(:model) { FactoryBot.build_stubbed(:project, experiencecatergory__c: Project::ExperienceCategory.pluck(:value).take(2)) }

    it do
      expect(subject.experience_categories).to eq %w[プロジェクト管理 ITプロジェクト管理]
    end
  end

  describe '#category_image' do
    subject { decorated.category_image(2) }

    let(:model) { FactoryBot.build_stubbed(:project, experiencecatergory__c: category.pluck(:value)) }
    let(:category) { Project::ExperienceCategory.take(1) }
    let(:slug) { category.first.slug }
    let(:version) { ProjectDecorator::IMAGE_VERSION }
    let(:category_image) { "https://res.cloudinary.com/miraiworksdev/image/upload/t_categories/v#{version}/categories/#{slug}/2.jpg" }

    context 'when category image not overrided' do
      it do
        is_expected.to eq category_image
      end
    end

    context 'when category image overrided' do
      let(:model) { FactoryBot.build_stubbed(:project, experiencecatergory__c: category.pluck(:value), web_photo__c: original_url) }

      let(:original_url) { "https://res.cloudinary.com/miraiworksdev/image/upload/v#{version}/categories/#{slug}/2.jpg" }
      let(:category_image) { "https://res.cloudinary.com/miraiworksdev/image/upload/t_categories/v#{version}/categories/#{slug}/2.jpg" }
      let(:version) { Faker::Number.number(digits: 10) }

      it do
        is_expected.to eq category_image
      end
    end
  end

  describe '#work_location' do
    let(:model) { FactoryBot.build(:project, work_prefectures__c: %w[千葉県 埼玉県]) }

    it do
      expect(subject.work_location).to eq '千葉県, 埼玉県'
    end
  end

  describe '#work_options' do
    let(:model) { FactoryBot.build(:project, work_options__c: %w[完全出社 完全リモート]) }

    it do
      expect(subject.work_options).to eq '完全出社, 完全リモート'
    end
  end

  describe '#jobposting_active?' do
    let(:model) { FactoryBot.build(:project, jobposting_isactive__c: true).decorate }

    it do
      expect(subject.jobposting_active?).to eq true
    end
  end

  describe '#contract_type', :focus do
    using RSpec::Parameterized::TableSyntax

    subject { model.contract_type }

    # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands, Layout/ExtraSpacing, Layout/SpaceAroundOperators
    where(:type, :result) do
      'FC事業案件'                       | '業務委託'
      '紹介予定案件（大人のインターン）' | '業務委託'
      '派遣契約案件'                     | '派遣契約'
      'CN案件'                           | '正社員'
      nil                                | nil
    end
    # rubocop:enable Lint/BinaryOperatorWithIdenticalOperands, Layout/ExtraSpacing, Layout/SpaceAroundOperators

    with_them do
      let(:model) { FactoryBot.build(:project, type:).decorate }

      it { is_expected.to eq result }
    end
  end
end
