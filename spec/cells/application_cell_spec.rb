# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationCell, type: :cell do
  let(:test_cell) do
    Class.new(ApplicationCell) do
      def show; end
    end
  end

  describe '#action_name' do
    before do
      stub_const('TestCell', test_cell)
    end

    let!(:target_cell) { cell(:test) }

    it do
      target_cell.call(:show)
      expect(target_cell.action_name).to eq(:show)
    end
  end
end
