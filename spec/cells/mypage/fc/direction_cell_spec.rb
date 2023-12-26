# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Fc::DirectionCell, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:described_cell) { cell(described_class, model, options) }
  let(:model) do
    DirectionDecorator.decorate_collection(
      FactoryBot.build_stubbed_list(:direction, count, *trait).map { |direction| ActiveType.cast(direction, Fc::ManageDirection::Direction) }
    )
  end
  let(:count) { 3 }
  let(:trait) { [:waiting_for_fc, { project: }] }
  let(:fc_user) { FactoryBot.build_stubbed(:fc_user, :activated) }
  let(:contact) { fc_user.contact }
  let(:project) { FactoryBot.create(:project, :with_client, fc_account: account, main_fc_contact: contact) }

  let(:profile) { ProfileDecorator.decorate(FactoryBot.build_stubbed(:sf_account_fc)) }
  before do
    allow_any_instance_of(Mypage::Fc::Direction::ItemCell).to receive(:fc_account_profile).and_return(profile)
  end

  context 'cell rendering' do
    describe 'rendering #show' do
      before do
        allow_any_instance_of(ApplicationCell).to receive(:current_fc_user).and_return(fc_user)
      end

      context 'when user is main fc' do
        let(:account) { contact.account }

        subject { described_cell.call(:show) }

        it do
          is_expected.to have_selector(:testid, 'fc/direction/item', count:)
            .and have_content('確認完了')
            .and have_content('修正申請')
        end

        describe 'filter' do
          using RSpec::Parameterized::TableSyntax

          where(:filter, :active_tab) do
            'all'            | 'すべて'
            'waiting_for_fc' | '未回答'
            nil              | '未回答'
            'completed'      | '回答済み'
            'rejected'       | '差し戻し'
          end

          with_them do
            let(:options) { { filter: } }
            it do
              is_expected.to have_selector('.btn-theme-02', text: active_tab)
            end
          end
        end
      end

      context 'when user is not main fc' do
        let(:account) { FactoryBot.build_stubbed(:account_fc, contacts: []) }

        subject { described_cell.call(:show) }

        it do
          is_expected.to have_selector(:testid, 'fc/direction/item', count:)
            .and have_content('確認完了')
            .and have_content('修正申請')
        end
      end
    end
  end
end
