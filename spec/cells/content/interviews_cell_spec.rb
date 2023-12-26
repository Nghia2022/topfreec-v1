# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Content::InterviewsCell, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:described_cell) { cell(described_class, model, options) }
  let(:model) { double('Interviews') }
  let(:interviews) { FactoryBot.build_stubbed_list(:interview, 2) }

  context 'cell rendering' do
    describe 'rendering #show' do
      subject { described_cell.call(:show) }

      before do
        allow(model).to receive(:decorate).and_return(Wordpress::InterviewDecorator.decorate_collection(interviews))
      end

      it do
        is_expected.to have_selector('div.case-study-item', count: 2)
      end
    end
  end
end
