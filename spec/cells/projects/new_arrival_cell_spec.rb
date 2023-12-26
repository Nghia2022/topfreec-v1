# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Projects::NewArrivalCell, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:described_cell) { cell(described_class, model, options) }
  let(:model) { FactoryBot.build_stubbed_list(:project, count).map(&:decorate) }
  let(:count) { 3 }

  context 'cell rendering' do
    describe 'rendering #show' do
      subject { described_cell.call(:show) }

      it do
        is_expected.to have_content '新着案件'
      end

      it do
        is_expected.to have_content model.first.project_name
      end

      it do
        is_expected.to have_link(href: project_path(model.first))
      end
    end
  end
end
