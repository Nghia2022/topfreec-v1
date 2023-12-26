# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Fc::ExperienceCell, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:contact) { FactoryBot.build_stubbed(:contact) }
  let(:model) { FactoryBot.create(:experience, :with_project, contact:).decorate }
  let(:described_cell) { cell(described_class, model, options) }

  context 'cell rendering' do
    describe 'rendering #row' do
      subject { described_cell.call(:row) }

      context 'has project' do
        it { is_expected.to have_content('フリーコンサルタント.jp') }
        it { is_expected.to have_content(model.description) }
        it { is_expected.to have_content(model.members_num.to_i) }
        it { is_expected.to have_content(model.role) }
        it { is_expected.to have_content('2019年04月') }
        it { is_expected.to have_content('2020年03月') }
        it { is_expected.to have_selector(:testid, 'mypage/fc/experience/row') }
        it { is_expected.to have_link(href: project_path(model.project)) }
        it { is_expected.not_to have_link(href: edit_mypage_fc_experience_path(model)) }
        it { is_expected.not_to have_link(href: mypage_fc_experience_path(model)) }
      end

      context 'doesnt has project' do
        let(:model) { FactoryBot.build_stubbed(:experience, contact:).decorate }

        it { is_expected.not_to have_content('案件詳細を見る') }

        it do
          is_expected.to have_selector(:testid, 'mypage/fc/experience/row')
        end
      end

      xcontext 'to_toggle_publish' do
        context 'published' do
          let(:model) { FactoryBot.build_stubbed(:experience, :published, contact:).decorate }

          it { is_expected.to have_link(href: close_mypage_fc_experience_path(model)) }
        end

        context 'closed' do
          let(:model) { FactoryBot.build_stubbed(:experience, :closed, contact:).decorate }

          it { is_expected.to have_link(href: publish_mypage_fc_experience_path(model)) }
        end
      end
    end
  end

  context 'cell methods' do
    describe '#freeconsultant' do
      context 'has project' do
        it do
          expect(described_cell.freeconsultant?).to eq(true)
        end
      end

      context 'doesnt has project' do
        let(:model) { FactoryBot.build_stubbed(:experience, contact:).decorate }

        it do
          expect(described_cell.freeconsultant?).to eq(false)
        end
      end
    end

    describe '#category' do
      it do
        expect(described_cell.category).to eq('フリーコンサルタント.jp')
      end
    end

    describe '#joined' do
      let(:model) { FactoryBot.build_stubbed(:experience, contact:, start_date__c: '2019-04-01').decorate }

      it do
        expect(described_cell.joined).to eq('2019年04月')
      end
    end

    describe '#left' do
      let(:model) { FactoryBot.build_stubbed(:experience, contact:, end_date__c: '2020-03-01').decorate }

      it do
        expect(described_cell.left).to eq('2020年03月')
      end
    end
  end
end
