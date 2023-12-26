# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Projects::FeaturedCell, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:described_cell) { cell(described_class, model, options) }
  let(:model) { ProjectDecorator.decorate_collection(FactoryBot.build_stubbed_list(:project, count)) }
  let(:count) { 3 }

  context 'cell rendering' do
    describe 'rendering #home' do
      subject { described_cell.call(:home) }

      it do
        is_expected.to have_content '注目案件'
      end

      it do
        is_expected.to [
          *model.map { |pj| have_content(pj.project_name) }
        ].inject(:and)
      end
    end

    describe 'rendering #mypage' do
      subject { described_cell.call(:mypage) }

      it do
        is_expected.to have_content '注目案件'
      end

      it do
        is_expected.to [
          *model.map { |pj| have_content(pj.project_name) }
        ].inject(:and)
      end
    end

    describe 'rendering #detail' do
      subject { described_cell.call(:detail) }

      it do
        is_expected.to have_content '注目案件'
      end

      it do
        is_expected.to [
          *model.map { |pj| have_content(pj.project_name) }
        ].inject(:and)
      end
    end
  end
end
