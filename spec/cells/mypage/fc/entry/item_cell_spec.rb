# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Fc::Entry::ItemCell, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:described_cell) { cell(described_class, model, options) }
  let(:model) { FactoryBot.build_stubbed(:matching, *trait).decorate }
  let(:project) { model.project }
  let(:trait) { [:with_project, { project_trait: }] }
  let(:project_trait) { [] }
  let(:fc_user) { FactoryBot.build_stubbed(:fc_user, :activated) }
  let(:response_body) { subject.body }

  context 'cell rendering' do
    describe 'rendering #row' do
      subject { described_cell.call(:row) }

      before do
        allow(described_cell).to receive(:current_fc_user).and_return(fc_user)
      end

      it do
        is_expected.to have_content(project.project_name)
          .and have_selector(:testid, 'mypage/fc/entry/item/row')
      end

      context 'compensations' do
        let(:project_trait) { [web_reward_min__c: 100, web_reward_max__c: 150] }

        it do
          is_expected.to have_content('100 〜 150万円')
        end
      end
    end
  end

  describe '#selection_status' do
    using RSpec::Parameterized::TableSyntax

    subject { described_cell.selection_status }

    where(:matching_status, :status_text) do
      :candidate                             | '応募中'
      :entry_target                          | '応募中'
      :entry_completed                       | '応募中'
      :fc_declined_entry                     | '辞退'
      :fc_declined_after_mtg                 | '辞退'
      :resume_submitted                      | '提案中'
      :mtg_booked                            | '提案中'
      :offer_contacted                       | '提案中'
      :win                                   | 'アサイン'
      :fc_declining                          | '辞退手続中'
      :not_eligible_for_entry                | 'クローズ'
      :client_ng_after_resume_submitted      | 'クローズ'
      :client_ng_after_mtg                   | 'クローズ'
      :lost_candidate                        | 'クローズ'
      :lost_entry_target                     | 'クローズ'
      :lost_entry_completed                  | 'クローズ'
      :lost_fc_declined_entry                | 'クローズ'
      :lost_not_eligible_for_entry           | 'クローズ'
      :lost_resume_submitted                 | 'クローズ'
      :lost_client_ng_after_resume_submitted | 'クローズ'
      :lost_mtg_booked                       | 'クローズ'
      :lost_fc_declining                     | 'クローズ'
      :lost_fc_declined_after_mtg            | 'クローズ'
      :lost_client_ng_after_mtg              | 'クローズ'
      :lost_offer_contacted                  | 'クローズ'
    end

    with_them do
      let(:model) { FactoryBot.build_stubbed(:matching, matching_status__c: matching_status).decorate }

      it do
        is_expected.to eq status_text
      end
    end
  end

  describe '#application_date' do
    subject { described_cell.application_date }

    let(:date) { '2020/01/01' }
    let(:trait) do
      [
        :with_project,
        { createddate: Time.zone.parse(date) }
      ]
    end

    it do
      is_expected.to eq '2020年1月1日(水)'
    end
  end

  describe '#class_name_for_decline_button' do
    using RSpec::Parameterized::TableSyntax

    where(:can_decline, :class_name) do
      true | 'btn btn-theme-02-outline bs-small jsModalOpen'
      false | 'btn btn-theme-disabled bs-small'
    end
    with_them do
      before do
        allow(described_cell).to receive(:can_decline?).and_return(can_decline)
      end

      subject { described_cell.send(:class_name_for_decline_button) }

      it do
        is_expected.to eq class_name
      end
    end
  end
end
