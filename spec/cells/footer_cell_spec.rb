# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FooterCell, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:model) { nil }
  let(:described_cell) { cell(described_class) }

  context 'cell rendering' do
    describe 'rendering #show' do
      subject { described_cell.call(:show) }

      it do
        is_expected.to have_selector(:testid, 'footer/show')
      end
    end
  end
end
