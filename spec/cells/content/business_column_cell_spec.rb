# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Content::BusinessColumnCell, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:described_cell) { cell(described_class, model, options) }
  let(:model) { FactoryBot.build_stubbed(:business_column).decorate }
  let(:term) { FactoryBot.build(:wp_term) }

  before do
    allow_any_instance_of(Wordpress::BusinessColumn).to receive(:terms).and_return([term])
    FeatureSwitch.enable :temporary_disabled
  end

  context 'cell rendering' do
    describe 'rendering #show' do
      subject { described_cell.call(:show) }

      it do
        is_expected.to have_content(model.post_title)
          .and have_link(href: corp_business_column_path(model))
      end
    end

    describe 'rendering #detail' do
      subject { described_cell.call(:detail) }

      it do
        is_expected.to have_content(model.post_title)
          .and have_link('フリーコンサルタント.jpを詳しく知る', href: service_page_path)
          .and have_link('高品質のコンサルタント案件を探す', href: projects_path)
      end

      context 'cached', cache: true do
        it do
          subject
          expect(described_cell).to be_cache(:detail)
        end
      end
    end

    describe 'rendering #latest_column' do
      subject { described_cell.call(:latest_column) }

      it do
        is_expected.to have_content(model.post_title)
          .and have_link(href: corp_business_column_path(model))
      end
    end

    describe 'rendering #tags' do
      subject { described_cell.call(:tags) }

      it { is_expected.to have_content(term.name) }
    end

    describe 'rendering #recommended' do
      subject { described_cell.call(:recommended) }

      it { is_expected.to have_content('こちらの記事もオススメです') }
    end
  end

  describe '#detail_path' do
    subject { described_cell.detail_path }

    it do
      is_expected.to eq(corp_business_column_path(model))
        .and not_ending_with('/')
    end
  end

  pending '#column_date'
end
