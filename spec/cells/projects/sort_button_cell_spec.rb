# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Projects::SortButtonCell, type: :cell do
  controller ApplicationController

  let(:options) { { search_params: } }
  let(:model) { projects }
  let(:projects) { FactoryBot.build_stubbed_list(:project, 2) }
  let(:described_cell) { cell(described_class, model, options) }
  let(:search_params) { {} }

  context 'cell rendering' do
    describe 'rendering #show' do
      subject { described_cell.call(:show) }

      it do
        is_expected.to have_selector('a[data-type=new]', class: 'btn bs-small btn-theme-02')
        .and have_selector('a[data-type=compensation]', class: 'btn bs-small')
        .and have_link('新着順', href: '/project?sort=createddate')
        .and have_link('報酬順', href: '/project?sort=compensation')
      end

      context 'with path option' do
        subject { described_cell.call(:show, path: :featured_projects_path) }

        it do
          is_expected.to have_link('新着順', href: '/project/featured?sort=createddate')
            .and have_link('報酬順', href: '/project/featured?sort=compensation')
        end
      end
    end
  end

  describe '#link_class' do
    context 'sort_type nil' do
      it 'class active' do
        expect(described_cell.link_class(:createddate).split).to include('btn-theme-02')
      end

      it do
        expect(described_cell.link_class(:compensation).split).to_not include('btn-theme-02')
      end
    end

    context 'sort_type createddate' do
      let(:search_params) { { sort: 'createddate' } }

      it 'class active' do
        expect(described_cell.link_class(:createddate).split).to include('btn-theme-02')
      end

      it do
        expect(described_cell.link_class(:compensation).split).to_not include('btn-theme-02')
      end
    end

    context 'sort_type createddate' do
      let(:search_params) { { sort: 'compensation' } }

      it do
        expect(described_cell.link_class(:createddate).split).to_not include('btn-theme-02')
      end

      it 'class active' do
        expect(described_cell.link_class(:compensation).split).to include('btn-theme-02')
      end
    end
  end

  describe '#projects_path_sort_by' do
    it do
      expect(described_cell.projects_path_sort_by(:createddate)).to eq '/project?sort=createddate'
    end

    it do
      expect(described_cell.projects_path_sort_by(:compensation)).to eq '/project?sort=compensation'
    end

    context 'was search' do
      let(:search_params) { { keyword: 'test', occupation: 'PM/PMO', compensation_id: 1, work_location: 'hokkaido' } }

      it do
        expect(described_cell.projects_path_sort_by(:compensation)).to eq '/project?compensation_id=1&keyword=test&occupation=PM%2FPMO&sort=compensation&work_location=hokkaido'
      end
    end
  end
end
