# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Fc::TutorialCell, type: :cell do
  controller ApplicationController

  let(:described_cell) { cell(described_class) }
  let(:cookies) { ActionDispatch::Request.empty.cookie_jar }

  context 'cell rendering' do
    describe 'rendering #show' do
      subject { described_cell.call(:show, cookies) }

      context 'when enabled flag' do
        before do
          cookies.permanent[:enable_tutorial] = '1'
        end

        it do
          is_expected.to have_content('Tutorial (チュートリアル)')
        end
      end

      context 'when disabled flag' do
        it do
          is_expected.not_to have_content('Tutorial (チュートリアル)')
        end
      end
    end
  end
end
