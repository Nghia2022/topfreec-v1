# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchBoxCell, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:described_cell) { cell(described_class, model, options) }
  let(:model) { nil }

  context 'cell rendering' do
    describe 'rendering #show' do
      subject { described_cell.call(:show) }

      it { is_expected.to have_content('検索する') }
    end
  end
end
