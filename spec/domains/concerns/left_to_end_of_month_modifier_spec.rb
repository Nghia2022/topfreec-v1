# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LeftToEndOfMonthModifier, type: :model do
  describe '#left=' do
    let(:klass) do
      Class.new do
        include ActiveModel::Model
        include ActiveModel::Attributes
        prepend LeftToEndOfMonthModifier

        attribute :left, :date
      end
    end

    let(:model) { klass.new }

    before do
      model.left = left_data
    end

    context 'receive date object' do
      let(:left_data) { '2020-01-01' }

      it 'modify to end of month' do
        expect(model.left).to eq '2020-01-31'.to_date
      end
    end

    context 'receive date selectable hash object' do
      let(:left_data) { { 1 => 2020, 2 => 6, 3 => 31 } }

      it 'modify to end of month' do
        expect(model.left).to eq '2020-06-30'.to_date
      end
    end
  end
end
