# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Fc::Direction::ItemCell, type: :cell do
  controller ApplicationController

  let(:fc_user) { FactoryBot.build_stubbed(:fc_user, :activated) }
  let(:options) { {} }
  let(:described_cell) { cell(described_class, model, options) }
  let(:model) { ActiveType.cast(FactoryBot.create(:direction, *trait), Fc::ManageDirection::Direction).decorate(context: { user: fc_user }) }
  let(:profile) { ProfileDecorator.decorate(FactoryBot.build_stubbed(:sf_account_fc)) }
  let(:project) { model.project }
  let(:trait) { [:with_project, { project_trait: }] }
  let(:project_trait) { [:with_client] }

  before do
    allow_any_instance_of(described_class).to receive(:fc_account_profile).and_return(profile)
  end

  context 'cell rendering' do
    before do
      allow(described_cell).to receive(:current_fc_user).and_return(fc_user)
    end

    describe 'rendering #row' do
      subject { described_cell.call(:row) }

      it do
        is_expected.to have_content(project.client_name)
      end
    end

    describe 'rendering button' do
      using RSpec::Parameterized::TableSyntax

      where(:status, :action, :label, :disabled, :visible) do
        :waiting_for_fc | :approve | '確認完了'   | false | true
        :waiting_for_fc | :reject  | '修正申請'   | false | true
        :completed      | :approve | '確認完了済' | true | true
        :completed      | :reject  | '修正申請'   | true  | false
        :rejected       | :approve | '確認完了'   | true  | true
        :rejected       | :reject  | '修正申請'   | true  | true
      end

      with_them do
        let(:project_trait) { [:with_client, { main_fc_contact: fc_user.contact }] }

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

    describe 'rendering buttons' do
      subject { described_cell.buttons }

      context 'user is owner of project' do
        let(:trait) { [:waiting_for_fc, :with_project, { project_trait: }] }
        let(:project_trait) { [:with_client, { main_fc_contact: fc_user.contact }] }

        it do
          is_expected.to be_present
        end
      end

      context 'user is not owner of project' do
        it do
          is_expected.to be_blank
        end
      end
    end

    describe '#status' do
      using RSpec::Parameterized::TableSyntax

      subject { described_cell.status }

      where(:status, :text) do
        :waiting_for_fc | '未回答'
        :completed | '回答済み'
        :rejected | '保留'
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

    describe '#approved_data' do
      subject { described_cell.approved_date }

      let(:date) { Time.zone.parse('2020/01/01') }
      let(:trait) do
        [
          :with_project,
          {
            approveddatebyfc__c: date
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
  end
end
