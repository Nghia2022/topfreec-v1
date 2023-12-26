# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ConversionCell, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:model) { nil }
  let(:described_cell) { cell(described_class, model, options) }
  let(:session_id) { SecureRandom.uuid }

  before do
    allow(described_cell).to receive(:session_id).and_return(session_id)
    allow(described_cell).to receive(:conversion_needed?).and_return(is_conversion_needed)
  end

  context '#show' do
    subject { described_cell.call(:show).to_s }

    context 'when conversion_needed? is true' do
      let(:is_conversion_needed) { true }

      it do
        is_expected.to match('gtm.js')
          .and match('indeed')
          .and match('valuecommerce')
          .and match(session_id)
      end
    end

    context 'when conversion_needed? is false' do
      let(:is_conversion_needed) { false }

      it do
        is_expected.not_to match(/gtm.js|indeed|valuecommerce|#{session_id}/)
      end
    end
  end
end
