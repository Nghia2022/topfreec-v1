# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Client::Direction::ItemCell, type: :cell do
  controller ApplicationController

  let(:client_user) { FactoryBot.build_stubbed(:client_user) }
  let(:options) { {} }
  let(:described_cell) { cell(described_class, model, options) }
  let(:model) { ActiveType.cast(FactoryBot.create(:direction, *trait), Client::ManageDirection::Direction).decorate(context: { user: client_user }) }
  let(:profile) { ProfileDecorator.decorate(FactoryBot.build_stubbed(:sf_account_fc)) }
  let(:project) { model.project }
  let(:trait) { [:with_project, { project_trait: }] }
  let(:project_trait) { [:with_client] }

  before do
    allow_any_instance_of(described_class).to receive(:fc_account_profile).and_return(profile)
  end

  context 'cell rendering' do
    before do
      allow(described_cell).to receive(:current_client_user).and_return(client_user)
    end

    describe 'rendering #row' do
      subject { described_cell.call(:row) }

      it do
        is_expected.to have_content(model.name)
      end
    end

    describe 'rendering buttons' do
      using RSpec::Parameterized::TableSyntax

      where(:status, :action, :label, :disabled, :visible) do
        :waiting_for_client | :approve | '確認完了'   | false | true
        :waiting_for_client | :reject  | '修正申請'   | false | true
        :waiting_for_fc     | :approve | '確認完了済' | true | true
        :waiting_for_fc     | :reject  | '修正申請' | true | false
        :completed          | :approve | '確認完了済' | true | true
        :completed          | :reject  | '修正申請'   | true  | false
        :rejected           | :approve | '確認完了'   | true  | true
        :rejected           | :reject  | '修正申請'   | true  | true
      end

      with_them do
        subject { described_cell.call(action) }

        before do
          model.status__c = status
        end

        it do
          if visible
            is_expected.to have_button(label, disabled:)
          else
            is_expected.not_to have_button(label)
          end
        end
      end
    end
  end

  describe '#status' do
    using RSpec::Parameterized::TableSyntax

    subject { described_cell.status }

    where(:status, :text) do
      :waiting_for_client | '未回答'
      :waiting_for_fc | '回答済み'
      :completed | '回答済み'
      :rejected | '差し戻し'
    end

    with_them do
      let(:trait) do
        [
          :with_project,
          { status__c: status }
        ]
      end

      it do
        is_expected.to eq text
      end
    end
  end

  describe '#approved_date' do
    subject { described_cell.approved_date }

    let(:date) { Time.zone.parse('2020/01/01') }
    let(:trait) do
      [
        :with_project,
        {
          approveddatebycl__c: date
        }
      ]
    end

    it do
      is_expected.to eq '2020年1月1日（水）'
    end
  end

  describe '#button_disabled' do
    subject { described_cell.button_disabled(can_reject) }

    context 'can reject' do
      let(:can_reject) { true }

      it { is_expected.to eq('') }
    end

    context 'can not reject' do
      let(:can_reject) { false }

      it { is_expected.to eq('disabled') }
    end
  end

  describe '#button_color' do
    subject { described_cell.button_color(:approve, can_approve) }

    context 'can approve' do
      let(:can_approve) { true }

      it { is_expected.to include('btn-theme-02 bs-small') }
    end

    context 'can not approve' do
      let(:can_approve) { false }

      it { is_expected.to eq('btn-theme-disabled bs-small') }
    end
  end

  describe '#fc_name' do
    subject { described_cell.fc_name }

    context 'when fc account is blank' do
      let(:profile) { nil }

      it { is_expected.to be_nil }
    end

    context 'when fc account exists' do
      it { is_expected.to eq(profile.full_name) }
    end
  end
end
