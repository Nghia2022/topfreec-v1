# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaginatorCell, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:params) do
    {
      controller: 'projects',
      action:     'index'
    }
  end
  let(:stub) { double('collection') }
  let(:model) { PaginatingDecorator.decorate(stub) }
  let(:described_cell) { cell(described_class, model, options) }

  context 'cell rendering' do
    describe 'rendering #show' do
      subject { described_cell.call(:show) }

      before do
        allow(controller).to receive(:params).and_return(ActionController::Parameters.new(params))
      end

      context 'when paginator has 2 pages' do
        before do
          allow(stub).to receive(:map).and_return([])
          allow(stub).to receive(:total_pages).and_return(2)
          allow(stub).to receive(:current_page).and_return(1)
          allow(stub).to receive(:limit_value).and_return(25)
          allow(stub).to receive(:next_page).and_return(2)
        end

        it do
          is_expected.to have_link('2', href: '/project?page=2')
          .and have_link(class: 'next page-numbers', href: '/project?page=2')
        end
      end

      context 'when paginator has no page' do
        before do
          allow(stub).to receive(:map).and_return([])
          allow(stub).to receive(:total_pages).and_return(1)
          allow(stub).to receive(:current_page).and_return(1)
          allow(stub).to receive(:limit_value).and_return(25)
          allow(stub).to receive(:next_page).and_return(nil)
        end

        it do
          is_expected.to have_no_link('2', href: '/project?page=2')
          .and have_no_link(href: '/project?page=2')
        end
      end
    end
  end
end
