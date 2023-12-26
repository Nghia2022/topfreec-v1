# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Fc::Settings::ServicesCell, type: :cell do
  controller ApplicationController

  let(:described_cell) { cell(described_class, nil, *options) }
  let(:contact) { double('Contact') }
  let(:options) { [contact_for_ml_reject: contact] }

  context 'cell rendering' do
    describe 'rendering #show' do
      subject { described_cell.call(:show) }

      before do
        allow(described_cell).to receive(:current_user).and_return(fc_user)
        allow(contact).to receive(:ml_reject?).and_return(true)
      end

      context 'when fc_user is fc' do
        let(:fc_user) { FactoryBot.build_stubbed(:fc_user, :activated) }

        it do
          is_expected.to have_selector(:testid, 'mypage/fc/settings/services/show')
              .and have_content('サービス利用状況')
        end
      end

      context 'when fc_user is fc company' do
        let(:fc_user) { FactoryBot.build_stubbed(:fc_user, :fc_company) }

        it do
          is_expected.to have_no_selector(:testid, 'mypage/fc/settings/services/show')
              .and have_no_content('サービス利用状況')
        end
      end
    end
  end
end
