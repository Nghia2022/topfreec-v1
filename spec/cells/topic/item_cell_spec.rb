# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Topic::ItemCell, type: :cell do
  controller ApplicationController

  let(:described_cell) { cell(described_class, collection: models) }
  let(:models) { FactoryBot.build_list(:wp_topic, 1) }

  context 'cell rendering' do
    describe 'rendering #row' do
      subject { described_cell.call(:row) }

      it do
        is_expected.to have_xpath '//a["https://mirai-works.co.jp/interview/m037/"]'
        is_expected.to have_content '前編：株式会社MOVED　代表取締役　渋谷雄大氏インタビュー『みらいの働き方 ～先進企業インタ...'
      end
    end
  end
end
