# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompensationFormattable do
  describe 'Current' do
    shared_context 'scarecrow model' do
      let(:model) do
        double('scarecrow').tap do |this|
          allow(this).to receive(:compensation_min).and_return(compensation_min)
          allow(this).to receive(:compensation_max).and_return(compensation_max)
          this.extend ActionView::Helpers::TagHelper
          this.extend(described_class::Current)
        end
      end
    end

    describe '#compensations_for_abstract' do
      using RSpec::Parameterized::TableSyntax

      subject { model.compensations_for_abstract }

      # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
      where(:compensation_min, :compensation_max, :result) do
        100.0 | 150.0 | '100-150<span class="currency">万円</span>'
        100.0 | nil   | '100<span class="currency">万円</span>-応相談'
        nil   | 150.0 | ''
        nil   | nil   | ''
        100.0 | 100.0 | '100<span class="currency">万円</span>'
      end
      # rubocop:enable Lint/BinaryOperatorWithIdenticalOperands

      with_them do
        include_context 'scarecrow model'

        it { is_expected.to eq result }
      end
    end

    describe '#compensations_for_details' do
      using RSpec::Parameterized::TableSyntax

      subject { model.compensations_for_details }

      # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
      where(:compensation_min, :compensation_max, :result) do
        100.0 | 150.0 | '100 〜 150<span class="currency">万円</span>'
        100.0 | nil   | '100<span class="currency">万円</span> 〜 応相談'
        nil   | 150.0 | ''
        nil   | nil   | ''
        100.0 | 100.0 | '100<span class="currency">万円</span>'
      end
      # rubocop:enable Lint/BinaryOperatorWithIdenticalOperands

      with_them do
        include_context 'scarecrow model'

        it { is_expected.to eq result }
      end
    end
  end

  describe 'V2022' do
    shared_context 'scarecrow model' do
      let(:model) do
        double('scarecrow').tap do |this|
          allow(this).to receive(:compensation_min).and_return(compensation_min)
          allow(this).to receive(:compensation_max).and_return(compensation_max)
          this.extend ActionView::Helpers::TagHelper
          this.extend(described_class::V2022)
        end
      end
    end

    describe '#compensations_for_abstract', :focus do
      using RSpec::Parameterized::TableSyntax

      subject { model.compensations_for_abstract }

      # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
      where(:compensation_min, :compensation_max, :result) do
        100.0 | 150.0 | '100-150万円'
        100.0 | nil   | '100万円-応相談'
        nil   | 150.0 | '150万円'
        nil   | nil   | ''
        100.0 | 100.0 | '100万円'
      end
      # rubocop:enable Lint/BinaryOperatorWithIdenticalOperands

      with_them do
        include_context 'scarecrow model'

        it { is_expected.to eq result }
      end
    end

    describe '#compensations_for_details', :focus do
      using RSpec::Parameterized::TableSyntax

      subject { model.compensations_for_details }

      # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
      where(:compensation_min, :compensation_max, :result) do
        100.0 | 150.0 | '100〜150万円'
        100.0 | nil   | '100万円〜応相談'
        nil   | 150.0 | '150万円'
        nil   | nil   | ''
        100.0 | 100.0 | '100万円'
      end
      # rubocop:enable Lint/BinaryOperatorWithIdenticalOperands

      with_them do
        include_context 'scarecrow model'

        it { is_expected.to eq result }
      end
    end
  end
end
