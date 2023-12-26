# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Projects::StatsCell, type: :cell do
  controller ApplicationController

  let(:options) { { search_params: } }
  let(:model) { projects }
  let(:projects) do
    FactoryBot.create_list(:project, 2)
    Project.all.page(1)
  end
  let(:described_cell) { cell(described_class, model, options) }

  context 'cell rendering' do
    describe 'rendering #show' do
      subject { described_cell.call(:show) }
      let(:options) { { form: } }
      let(:form) { Projects::SearchForm.new(form_attributes) }
      let(:form_attributes) { {} }

      context 'when search conditions are all blank' do
        it do
          is_expected.to have_no_content(/\d+件中 \d+件/)
        end
      end

      context 'when search conditions are not blank' do
        let(:form_attributes) { { categories: 'プロジェクト管理' } }
        it do
          is_expected.to have_content(/\d+件中/)
            .and have_content(/\d+件を表示/)
        end
      end
    end
  end
end
