# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Content::WorkstyleCell, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:described_cell) { cell(described_class, model, options) }
  let(:model) { FactoryBot.build_stubbed(:workstyle).decorate }

  context 'cell rendering' do
    describe 'rendering #show' do
      subject { described_cell.call(:show) }

      it do
        is_expected.to have_content(model.post_title)
          .and have_link(href: content_workstyle_path(model.post_name))
      end
    end

    describe 'rendering #detail' do
      subject { described_cell.call(:detail) }

      it do
        is_expected.to have_content(model.post_title)
          .and have_link('フリーコンサルタント.jpを詳しく知る', href: service_page_path)
          .and have_link('高品質のコンサルタント案件を探す', href: projects_path)
      end

      context 'cached', :cache do
        it do
          subject
          expect(described_cell).to be_cache(:detail)
        end
      end
    end

    describe 'rendering #latest_workstyle' do
      subject { described_cell.call(:latest_workstyle) }

      it do
        is_expected.to have_content(model.post_title)
          .and have_link(href: content_workstyle_path(model))
      end
    end
  end

  describe '#detail_path' do
    subject { described_cell.detail_path }

    it do
      is_expected.to eq(content_workstyle_path(model))
        .and ending_with('/')
    end
  end

  pending '#workstyle_date'
end
