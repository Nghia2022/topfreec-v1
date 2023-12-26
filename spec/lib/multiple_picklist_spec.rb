# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MultiplePicklist, type: :lib do
  describe '.dump' do
    context 'single value' do
      let(:values) { %w[a] }

      it do
        expect(MultiplePicklist.dump(values)).to eq('a')
      end
    end

    context 'multiple values' do
      let(:values) { %w[a b c] }

      it do
        expect(MultiplePicklist.dump(values)).to eq('a;b;c')
      end
    end

    context 'nil' do
      let(:values) { nil }

      it do
        expect(MultiplePicklist.dump(values)).to eq(nil)
      end
    end

    context 'empty' do
      let(:values) { [] }

      it do
        expect(MultiplePicklist.dump(values)).to eq(nil)
      end
    end
  end

  describe '.load' do
    context 'multiple values' do
      let(:source) { 'a;b;c' }

      it do
        expect(MultiplePicklist.load(source)).to eq(%w[a b c])
      end
    end

    context 'nil' do
      let(:source) { nil }

      it do
        expect(MultiplePicklist.load(source)).to eq(nil)
      end
    end
  end
end
