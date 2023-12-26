# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Content::BusinessColumnsCell, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:described_cell) { cell(described_class, model, options) }
  let(:model) { double('Business Columns') }
  let(:business_columns) { FactoryBot.build_stubbed_list(:business_column, 2) }
  let(:term) { FactoryBot.build(:wp_term) }

  before do
    allow_any_instance_of(Wordpress::BusinessColumn).to receive(:terms).and_return([term])
  end

  context 'cell rendering' do
    shared_examples 'cache action' do
      before do
        allow(model).to receive(:cache_key_with_version).and_return('cache')
      end

      it do
        subject
        expect(described_cell).to be_cache(action)
      end
    end

    subject { described_cell.call(action) }

    describe 'rendering #show' do
      let(:action) { :show }

      before do
        allow(model).to receive(:preload_thumbnails)
        allow(model).to receive(:decorate).and_return(Wordpress::BusinessColumnDecorator.decorate_collection(business_columns))
      end

      it do
        is_expected.to have_selector('li', count: 2)
      end

      context 'cached', :cache do
        it_behaves_like 'cache action'
      end
    end

    describe 'rendering #latest_column' do
      let(:action) { :latest_column }

      before do
        allow(model).to receive(:preload_thumbnails)
        allow(model).to receive(:decorate).and_return(Wordpress::BusinessColumnDecorator.decorate_collection(business_columns))
      end

      it do
        is_expected.to have_selector('li', count: 2)
      end

      context 'cached', :cache do
        it_behaves_like 'cache action'
      end
    end
  end
end
