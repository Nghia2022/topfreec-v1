# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Client::DirectionCell, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:described_cell) { cell(described_class, model, options) }
  let(:model) do
    DirectionDecorator.decorate_collection(
      FactoryBot.build_stubbed_list(:direction, count, *trait).map { |direction| ActiveType.cast(direction, Client::ManageDirection::Direction) }
    )
  end
  let(:count) { 3 }
  let(:trait) { [:waiting_for_client, { project: }] }
  let(:client_user) { FactoryBot.build_stubbed(:client_user, :with_contact) }
  let(:contact) { client_user.contact }
  let(:project) { FactoryBot.create(:project, main_cl_contact: contact) }

  let(:profile) { ProfileDecorator.decorate(FactoryBot.build_stubbed(:sf_account_fc)) }
  before do
    allow_any_instance_of(Mypage::Client::Direction::ItemCell).to receive(:fc_account_profile).and_return(profile)
  end

  context 'cell rendering' do
    describe 'rendering #show' do
      before do
        allow_any_instance_of(ApplicationCell).to receive(:current_client_user).and_return(client_user)
      end

      context 'when user is main cl' do
        let(:account) { contact.account }

        subject { described_cell.call(:show) }

        it do
          is_expected.to have_selector(:testid, 'client/direction/item/row', count:)
            .and have_button('確認完了')
            .and have_button('修正申請')
        end

        describe 'filter' do
          using RSpec::Parameterized::TableSyntax

          where(:filter, :active_tab) do
            'all'                | 'すべて'
            'waiting_for_client' | '未回答'
            nil                  | '未回答'
            'completed'          | '回答済み'
            'rejected'           | '差し戻し'
          end

          with_them do
            let(:options) { { filter: } }
            it { is_expected.to have_selector('a', class: 'btn-theme-02', text: active_tab) }
          end
        end
      end

      context 'when user is not main cl' do
        let(:account) { FactoryBot.build_stubbed(:account_client, contacts: []) }

        subject { described_cell.call(:show) }

        it do
          is_expected.to have_selector(:testid, 'client/direction/item/row', count:)
          is_expected.not_to have_selector('table a', text: '確認完了')
          is_expected.not_to have_selector('table a', text: '修正申請')
        end
      end
    end
  end
end
