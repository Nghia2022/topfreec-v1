# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Fc::EntryCell, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:described_cell) { cell(described_class, model, options) }
  let(:model) { MatchingDecorator.decorate_collection(FactoryBot.build_stubbed_list(:matching, count, *trait)) }
  let(:count) { 3 }
  let(:trait) { [:with_project, { project_trait: }] }
  let(:project_trait) { [] }
  let(:fc_user) { FactoryBot.build_stubbed(:fc_user, :activated) }
  let(:account) { instance_double(Account::Fc, matchings:) }
  let(:matchings) { double(model, for_entry_count:) }
  let(:for_entry_count) { double('for_entry_count', count:) }

  context 'cell rendering' do
    describe 'rendering #show' do
      subject { described_cell.call(:show) }

      before do
        allow(fc_user).to receive(:account).and_return(account)

        allow(described_cell).to receive(:current_user).and_return(fc_user)
        allow_any_instance_of(ApplicationCell).to receive(:current_fc_user).and_return(fc_user)
      end

      it do
        is_expected.to have_selector(:testid, 'mypage/fc/entry/show')
      end

      it do
        is_expected.to have_selector(:testid, 'mypage/fc/entry/item/row', count:)
      end
    end

    describe 'rendering #message' do
      before do
        allow(fc_user).to receive(:account).and_return(account)
        allow(described_cell).to receive(:current_user).and_return(fc_user)
      end

      subject do
        described_cell.call(:message)
      end

      context 'when no entry' do
        let(:options) { { entry_limit: 3 } }
        let(:count) { 0 }

        it { is_expected.to have_content('3件までご応募可能です') }
      end

      context 'when reached limit' do
        let(:options) { { entry_limit: 3 } }

        it { is_expected.to have_content('同時にご応募可能な上限3件に達しております') }
      end

      context 'when remaining' do
        let(:options) { { entry_limit: 5 } }

        it { is_expected.to have_content('残り2/5件ご応募可能です') }
      end
    end
  end
end
