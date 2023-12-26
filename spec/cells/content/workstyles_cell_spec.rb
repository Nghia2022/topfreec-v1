# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Content::WorkstylesCell, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:described_cell) { cell(described_class, model, options) }
  let(:model) { double('Workstyles') }
  let(:columns) { FactoryBot.build_stubbed_list(:workstyle, 2) }

  context 'cell rendering' do
    subject { described_cell.call(action) }

    shared_examples 'cache action' do
      before do
        allow(model).to receive(:cache_key_with_version).and_return('cache')
      end

      it do
        subject
        expect(described_cell).to be_cache(action)
      end
    end

    before do
      allow(model).to receive(:preload_meta_images)
      allow(model).to receive(:decorate).and_return(Wordpress::WorkstyleDecorator.decorate_collection(columns))
    end

    describe 'rendering #show' do
      let(:action) { :show }

      it do
        is_expected.to have_selector('li', count: 2)
      end

      context 'cached', :cache do
        it_behaves_like 'cache action'
      end
    end

    describe 'rendering #latest_workstyle' do
      let(:action) { :latest_workstyle }

      it do
        is_expected.to have_selector('li', count: 2)
      end

      context 'cached', :cache do
        it_behaves_like 'cache action'
      end
    end
  end
end
