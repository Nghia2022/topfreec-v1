# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Content::ProjectsCell, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:described_cell) { cell(described_class, model, options) }
  let(:model) { double('Projects') }
  let(:projects) { FactoryBot.build_stubbed_list(:project, 2) }

  context 'cell rendering' do
    describe 'rendering #show' do
      subject { described_cell.call(:show) }

      before do
        allow(model).to receive(:decorate).and_return(ProjectDecorator.decorate_collection(projects))
      end

      it do
        is_expected.to have_selector('a', count: 2)
      end

      context 'cached', :cache do
        before do
          allow(model).to receive(:cache_key_with_version).and_return('cache')
        end

        it do
          subject
          expect(described_cell).to be_cache(:show)
        end
      end
    end
  end
end
