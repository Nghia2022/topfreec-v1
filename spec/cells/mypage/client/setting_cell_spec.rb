# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Client::SettingCell, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:described_cell) { cell(described_class, model, options) }
  let(:model) { ProfileDecorator.decorate(FactoryBot.build_stubbed(:sf_contact, attributes)) }
  let(:client_user) { FcUserDecorator.decorate(FactoryBot.build_stubbed(:fc_user)) }
  let(:attributes) { {} }

  before do
    allow(described_cell).to receive(:current_client_user).and_return(client_user)
  end

  context 'cell rendering' do
    describe 'rendering #show' do
      subject { described_cell.call(:show) }

      it do
        is_expected.to have_selector(:testid, 'mypage/client/setting/show')
          .and have_content(client_user.email)
          .and have_content('メールアドレス')
          .and have_content('パスワード')
          .and have_content('編集する')
      end
    end
  end
end
