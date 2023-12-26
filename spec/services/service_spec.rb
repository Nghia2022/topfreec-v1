# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Service do
  before do
    stub_const('DummyService', Class.new do
      include Service

      private

      def call
        'called'
      end
    end)

    stub_const('DummyServiceWithArgument', Class.new do
      include Service

      def initialize(param_a, param_b)
        @param_a = param_a
        @param_b = param_b
      end

      private

      def call
        "called with #{@param_a} #{@param_b}"
      end
    end)

    stub_const('DummyServiceWithKeywordArgument', Class.new do
      include Service

      def initialize(param:)
        @param = param
      end

      private

      def call
        "called with #{@param}"
      end
    end)
  end

  describe '.call' do
    subject { DummyService.call }

    it do
      is_expected.to eq 'called'
    end
  end

  describe '.with' do
    context 'with arguments' do
      subject { DummyServiceWithArgument.with('Hello', 'world').call }

      it do
        is_expected.to eq 'called with Hello world'
      end
    end

    context 'with keyword arguments' do
      subject { DummyServiceWithKeywordArgument.with(param: 'KEYWORD PARAM').call }

      it do
        is_expected.to eq 'called with KEYWORD PARAM'
      end
    end
  end
end
