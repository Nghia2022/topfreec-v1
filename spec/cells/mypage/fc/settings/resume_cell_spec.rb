# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Fc::Settings::ResumeCell, type: :cell do
  controller ApplicationController

  let(:described_cell) { cell(described_class, nil, *options) }
  let(:options) { [last_uploaded_at:, notice:] }
  let(:fc_user) { FactoryBot.build_stubbed(:fc_user, :activated) }

  before do
    allow(described_cell).to receive(:current_user).and_return(fc_user)
  end

  context 'cell rendering' do
    describe 'rendering #show' do
      let(:last_uploaded_at) { nil }
      let(:notice) { nil }

      subject { described_cell.call(:show) }

      context 'when last_uploaded_at is present' do
        let(:last_uploaded_at) { Time.current }

        it do
          is_expected.to have_selector(:testid, 'mypage/fc/settings/resume/show')
            .and have_content('アップロード日時')
        end
      end

      context 'when last_uploaded_at is blank' do
        it do
          is_expected.to have_selector(:testid, 'mypage/fc/settings/resume/show')
            .and have_no_content('アップロード日時')
        end
      end

      context 'when notice is present' do
        let(:notice) { 'レジュメをアップロードしました' }

        it do
          is_expected.to have_selector(:testid, 'mypage/fc/settings/resume/show')
            .and have_content('レジュメをアップロードしました')
        end
      end

      context 'when notice is blank' do
        it do
          is_expected.to have_selector(:testid, 'mypage/fc/settings/resume/show')
            .and have_no_content('レジュメをアップロードしました')
        end
      end
    end
  end
end
