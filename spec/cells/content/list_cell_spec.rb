# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Content::ListCell, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:described_cell) { cell(described_class, model, options) }
  let(:model) { FactoryBot.build(:column).decorate }

  context 'cell rendering' do
    describe '#show' do
      subject { described_cell.call(:show) }
      it do
        expect(described_cell).to receive(:slider)
        subject
      end
    end

    describe '#prev_slider' do
      subject { described_cell.call(:prev_slider) }

      before do
        allow(model).to receive(:prev_content).and_return(prev_content)
      end

      context 'with prev content' do
        let(:prev_content) { FactoryBot.build_stubbed(:column) }
        it { is_expected.to have_link('前の記事を読む', href: content_column_url(prev_content)) }
      end

      context 'without prev content' do
        let(:prev_content) { nil }
        it { is_expected.not_to have_link('前の記事を読む') }
      end
    end

    describe '#slider' do
      subject { described_cell.call(:slider) }
      it { is_expected.to have_link('記事一覧へ戻る', href: content_columns_url) }
    end

    describe '#next_slider' do
      subject { described_cell.call(:next_slider) }

      before do
        allow(model).to receive(:next_content).and_return(next_content)
      end

      context 'with next content' do
        let(:next_content) { FactoryBot.build_stubbed(:column) }
        it { is_expected.to have_link('次の記事を読む', href: content_column_url(next_content)) }
      end

      context 'without next content' do
        let(:next_content) { nil }
        it { is_expected.not_to have_link('次の記事を読む') }
      end
    end
  end
end
