# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TopicCell, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:described_cell) do
    cell(described_class, model, options).tap do |c|
      # Kaminari の paginate が controller と action を取得できないとエラーが出る対策
      # disable :reek:LongParameterList
      def c.paginate(scope, paginator_class: Kaminari::Helpers::Paginator, template: nil, **options)
        super(scope, paginator_class:, template:, **options.merge(params: { controller: 'welcome', action: 'index' }))
      end
    end
  end
  let(:model) { Wordpress::Topic.all.page(1) }

  context 'cell rendering' do
    shared_examples 'news' do |action|
      it do
        is_expected.to have_selector(:testid, 'cells/topic/show')
      end

      context 'cached', :cache do
        it do
          subject
          expect(described_cell).to be_cache(action)
        end
      end
    end

    describe 'rendering #show' do
      subject { described_cell.call(:show) }

      it_behaves_like 'news', :show

      it do
        is_expected.to have_link(class: 'next page-numbers')
      end
    end

    describe 'rendering #show_without_pagination' do
      subject { described_cell.call(:show_without_pagination) }

      it_behaves_like 'news', :show_without_pagination

      it do
        is_expected.to have_no_link(class: 'next page-numbers')
      end
    end
  end
end
