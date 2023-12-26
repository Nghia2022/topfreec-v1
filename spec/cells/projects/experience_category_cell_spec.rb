# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Projects::ExperienceCategoryCell, type: :cell do
  controller ApplicationController
  let(:options) { {} }
  let(:described_cell) { cell(described_class, model, options) }
  let(:model) { nil }

  describe 'cell rendering' do
    describe 'rencering #show' do
      subject { described_cell.call(:show) }
      let(:model) { Project::ExperienceCategory.all.sample }
      let!(:project_category_metum) { FactoryBot.create(:project_category_metum, work_category_main: model.value, slug: 'sample-slug') }

      # TODO: #3440 FeatureSwitchの分岐を削除
      describe ':new_project_category_meta of Feature Switch' do
        context 'with true' do
          before do
            FeatureSwitch.enable :new_project_category_meta
          end

          it { is_expected.to have_link(project_category_metum.work_category_main, href: slug_projects_path(project_category_metum.slug)) }
        end

        context 'with false' do
          it { is_expected.to have_link(href: projects_path(categories: [model.value])) }
        end
      end
    end
  end

  describe '#category_image_url' do
    subject { described_cell.send(:category_image_url) }
    let(:model) { instance_double('record', slug: 'slug') }

    it do
      is_expected.to a_string_ending_with 'categories/slug/menu.png'
    end
  end

  describe '#category_name' do
    subject { described_cell.send(:category_name) }
    let(:model) { instance_double('record', value: 'category name') }

    it do
      is_expected.to eq model.value
    end
  end
end
