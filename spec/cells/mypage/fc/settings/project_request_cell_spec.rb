# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Fc::Settings::ProjectRequestCell, :erb, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:described_cell) { cell(described_class, model, options) }

  context 'cell rendering' do
    describe 'rendering #show' do
      subject { described_cell.call(:show) }

      let(:model) do
        Fc::Settings::ProjectRequestForm.new(
          start_timing:   '2020/04/20',
          occupancy_rate: 60,
          requests:       Faker::Lorem.paragraphs(number: rand(3..7)).join("\n"),
          reward_min:     50,
          reward_desired: 100
        )
      end

      it do
        is_expected.to have_content('4月20日')
          .and have_content('週3日')
          .and have_content(model.requests.gsub(/\R/, ''))
          .and have_content("#{model.reward_min} 万円以上")
          .and have_content("#{model.reward_desired} 万円")
      end
    end
  end

  describe '#minimum_reward' do
    subject { described_cell.minimum_reward }

    context 'when reward_min is nil' do
      let(:model) { Fc::Settings::ProjectRequestForm.new(reward_min: nil) }

      it do
        is_expected.to eq '未回答'
      end
    end

    context 'when reward_min in present' do
      let(:model) { Fc::Settings::ProjectRequestForm.new(reward_min: 50) }

      it do
        is_expected.to eq '50 万円以上'
      end
    end
  end

  describe '#desired_reward' do
    subject { described_cell.desired_reward }

    context 'when reward_desired is nil' do
      let(:model) { Fc::Settings::ProjectRequestForm.new(reward_desired: nil) }

      it do
        is_expected.to eq '未回答'
      end
    end

    context 'when reward_desired in present' do
      let(:model) { Fc::Settings::ProjectRequestForm.new(reward_desired: 50) }

      it do
        is_expected.to eq '50 万円'
      end
    end
  end

  describe '#occupancy_rate' do
    subject { described_cell.occupancy_rate }
    let(:model) { Fc::Settings::ProjectRequestForm.new(occupancy_rate:) }

    using RSpec::Parameterized::TableSyntax

    # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
    where(:occupancy_rate, :text) do
      20  | '週1日'
      40  | '週2日'
      60  | '週3日'
      80  | '週4日'
      100 | '週5日'
      0   | nil
      nil | nil
    end
    # rubocop:enable Lint/BinaryOperatorWithIdenticalOperands

    with_them do
      it do
        is_expected.to eq text
      end
    end
  end
end
