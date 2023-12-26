# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TrackingCell, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:model) { nil }
  let(:described_cell) { cell(described_class, model, options) }

  describe '#head' do
    subject { described_cell.call(:head) }

    it do
      is_expected.to have_content('gtm.js')
        .and have_content('analytics')
    end
  end

  describe '#body_opening' do
    subject { described_cell.call(:body_opening).to_s }

    it do
      is_expected.to match('ns.html')
    end
  end
end
