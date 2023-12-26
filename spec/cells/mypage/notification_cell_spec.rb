# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::NotificationCell, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:model) { FactoryBot.build_stubbed_list(:receipt, 5, :with_notification, receiver: fc_user) }
  let(:described_cell) { cell(described_class, model, options) }
  let(:fc_user) { FactoryBot.build_stubbed(:fc_user) }

  context 'cell rendering' do
    describe 'rendering #show' do
      subject { described_cell.call(:show) }

      context 'valid' do
        it { is_expected.to have_content(model.first.subject) }
      end

      context 'notifications is empty' do
        let(:model) { [] }

        it { is_expected.to have_content('お知らせはありません') }
      end
    end

    describe 'rendering #item' do
      subject { described_cell.call(:item) }

      let(:model) { FactoryBot.build_stubbed(:receipt, :with_notification) }

      it { is_expected.to have_content(model.subject) }
    end
  end
end
