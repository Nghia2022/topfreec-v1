# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Content::BlogsCell, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:described_cell) { cell(described_class, model, options) }
  let(:model) { double('Blogs') }
  let(:blogs) { FactoryBot.build_stubbed_list(:ceo_blog, 2) }

  context 'cell rendering' do
    subject { described_cell.call(action) }

    before do
      allow(model).to receive(:preload_thumbnails)
      allow(model).to receive(:decorate).and_return(Wordpress::CeoBlogDecorator.decorate_collection(blogs))
      allow(model).to receive(:each_with_index).and_return(blogs)
      allow(model).to receive(:cache_key_with_version).and_return('cache')
    end

    describe 'rendering #show' do
      let(:action) { :show }

      it do
        is_expected.to have_selector('li', count: 2)
      end

      context 'cached', :cache do
        it do
          subject
          expect(described_cell).to be_cache(action)
        end
      end
    end

    describe 'rendering #latest_blog' do
      let(:action) { :latest_blog }

      before do
        allow(model).to receive(:preload_thumbnails)
      end

      it do
        is_expected.to have_selector('li', count: 2)
      end

      context 'cached', :cache do
        it do
          subject
          expect(described_cell).to be_cache(action)
        end
      end
    end
  end
end
