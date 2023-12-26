# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Projects::WorkLocationsCell, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:described_cell) { cell(described_class, model, options) }
  let(:model) { Project::WorkPrefecture.all }

  context 'cell rendering' do
    describe 'rendering #show' do
      subject { described_cell.call(:show) }

      it do
        is_expected.to have_content '勤務地から探す'
      end
    end
  end
end
