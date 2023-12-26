# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Fc::DashboardCell, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:described_cell) { cell(described_class, model, options) }
  let(:model) { FactoryBot.build_stubbed(:account_fc).decorate }

  context 'cell rendering' do
    describe 'rendering #show' do
      subject { described_cell.call(:show) }

      it do
        is_expected.to [
          have_content('情報更新日'),
          have_content('Web応募日'),
          have_content('業務指示'),
          have_content('応募履歴')
        ].inject(:and)
      end
    end
  end

  describe '#pending_directions' do
    subject { described_cell.send(:pending_directions) }

    context 'when pending directions is present' do
      let(:options) { { pending_directions_count: 1 } }

      it do
        is_expected.to eq 'あり'
      end
    end

    context 'when pending directions is empty' do
      let(:options) { { pending_directions_count: 0 } }

      it do
        is_expected.to eq 'なし'
      end
    end
  end
end
