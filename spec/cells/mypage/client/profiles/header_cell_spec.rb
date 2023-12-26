# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Client::Profiles::HeaderCell, type: :cell do
  context 'cell rendering' do
    controller ApplicationController

    let(:options) { {} }
    let(:model) { FactoryBot.build_stubbed(:client_user) }
    let(:described_cell) { cell(described_class, model, options) }

    context 'rendering #show' do
      subject { described_cell.call(:show) }
      it do
        is_expected.to have_link(text: '設定情報', href: mypage_client_settings_path)
      end
    end
  end
end
