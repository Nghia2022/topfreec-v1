# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Content::MenuCell, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:described_cell) { cell(described_class, model, options) }
  let(:model) { :column }

  context 'cell rendering' do
    describe 'rendering #show' do
      subject { described_cell.call(:show) }

      it { is_expected.to have_content('コラム') }

      context 'column' do
        let(:model) { :column }

        it do
          within('is-active') do
            is_expected.to have_link(href: content_columns_path)
              .and have_no_link(href: content_workstyles_path)
              .and have_no_link(href: content_blogs_path)
          end
        end
      end

      context 'workstyle' do
        let(:model) { :workstyle }

        it do
          within('is-active') do
            is_expected.to have_no_link(href: content_columns_path)
              .and have_link(href: content_workstyles_path)
              .and have_no_link(href: content_blogs_path)
          end
        end
      end

      context 'ceo_blog' do
        let(:model) { :ceo_blog }

        it do
          within('is-active') do
            is_expected.to have_no_link(href: content_columns_path)
              .and have_no_link(href: content_workstyles_path)
              .and have_link(href: content_blogs_path)
          end
        end
      end
    end
  end

  describe 'options' do
    describe ':title' do
      let(:options) { { title: 'Title' } }
      subject { described_cell.call(:show) }

      it do
        is_expected.to have_content('Title')
      end

      it do
        expect(described_cell.send(:title)).to eq 'Title'
      end
    end

    describe ':subtitle' do
      let(:options) { { subtitle: 'Sub title' } }
      subject { described_cell.call(:show) }

      it do
        is_expected.to have_content('Sub title')
      end

      it do
        expect(described_cell.send(:subtitle)).to eq 'Sub title'
      end
    end

    describe ':description' do
      let(:options) { { description: 'Description' } }
      subject { described_cell.call(:show) }

      it do
        is_expected.to have_content('Description')
      end

      it do
        expect(described_cell.send(:description)).to eq 'Description'
      end
    end
  end
end
