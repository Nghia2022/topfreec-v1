# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Content::ProjectCell, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:described_cell) { cell(described_class, model, options) }
  let(:model) { ProjectDecorator.decorate(project) }
  let(:project) { FactoryBot.build_stubbed(:project) }

  context 'cell rendering' do
    describe 'rendering #show' do
      subject { described_cell.call(:show) }

      it do
        is_expected.to have_selector('a', count: 1)
          .and have_content(model.project_name)
          .and have_link(href: project_path(project))
      end
    end
  end

  describe '#project_date' do
    let(:project) { FactoryBot.build_stubbed(:project, created_at: '2020-10-27 08:00') }

    subject { described_cell.send(:project_date) }

    it do
      is_expected.to eq '2020年10月27日(火)'
    end
  end
end
