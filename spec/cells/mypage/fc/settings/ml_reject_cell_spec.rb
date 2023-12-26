# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Fc::Settings::MlRejectCell, type: :cell do
  controller ApplicationController

  let(:described_cell) { cell(described_class, model) }
  let(:model) { FactoryBot.build_stubbed(:contact, *contact_traits).decorate }
  let(:contact_traits) { [ml_reject__c: false] }

  context 'cell rendering' do
    describe 'rendering #show' do
      subject { described_cell.call(:show) }

      describe 'render ml_reject button' do
        it do
          is_expected.to have_selector(:testid, 'mypage/fc/settings/ml_reject/show')
            .and have_link('利用中')
        end
      end
    end
  end

  describe '#toggle_button' do
    subject { Capybara.string(described_cell.toggle_button) }

    context 'when ml_reject is true' do
      let(:contact_traits) { [ml_reject__c: true] }

      it do
        is_expected.to have_link('停止中')
            .and have_selector('i', class: 'icon-slash')
      end
    end

    context 'when ml_reject is false' do
      let(:contact_traits) { [ml_reject__c: false] }

      it do
        is_expected.to have_link('利用中')
            .and have_selector('i', class: 'icon-check-circle')
      end
    end
  end
end
