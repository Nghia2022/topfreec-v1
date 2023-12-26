# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Projects::ExperienceCategoriesCell, type: :cell do
  controller ApplicationController
  let(:options) { {} }
  let(:described_cell) { cell(described_class, model, options) }
  let(:model) { Project::ExperienceCategory.all.take(10) }

  context 'cell rendering' do
    describe 'rendering #show' do
      subject { described_cell.call(:show) }

      it do
        is_expected.to have_selector(:testid, 'projects/experience_categories/show')
          .and have_selector(:testid, 'projects/experience_category/show', count: 10)
      end
    end
  end
end
