# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::SignOutCell, type: :cell do
  controller ApplicationController

  let(:sign_out_path) { '/sign_out' }
  let(:described_cell) { cell(described_class, nil, *options) }
  let(:options) { [sign_out_path:] }

  context 'cell rendering' do
    describe 'rendering #show' do
      subject { described_cell.call(:show) }

      it do
        is_expected.to have_selector(:testid, 'mypage/sign_out/show')
            .and have_link('ログアウト', href: sign_out_path)
      end
    end
  end
end
