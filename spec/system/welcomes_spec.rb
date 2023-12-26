# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Welcomes', type: :system do
  describe 'do not show tutorial' do
    it do
      visit root_url
      expect(page).not_to have_content('チュートリアル')
    end
  end

  describe 'OGP' do
    it do
      visit root_url

      expect(page).to [
        have_selector('meta[property="og:type"][content="website"]', visible: false),
        have_selector('meta[property="og:title"]', visible: false) do |tag|
          tag['content'] == '【フリーコンサルタント.jp】高年収／高単価の戦略・PMO・IT案件に特化したマッチングエージェント'
        end,
        have_selector('meta[property="og:description"]', visible: false) do |tag|
          tag['content'] == 'フリーコンサルタント.jpは、PMO案件をはじめPM,SAP,IT,戦略,新規事業,業務改革等の高額プロジェクト紹介。フリーランス人材のためのコンサルタント登録・募集、人材派遣のマッチングサービス。'
        end,
        have_selector('meta[property="og:url"]', visible: false) do |tag|
          tag['content'] == 'http://www.example.com/'
        end,
        have_selector('meta[property="og:image"]', visible: false) do |tag|
          tag['content'] == 'http://www.example.com/assets/images/ogp.png'
        end
      ].inject(:and)
    end
  end

  describe 'Twitter Card' do
    it do
      visit root_url

      expect(page).to [
        have_selector('meta[name="twitter:card"][content="summary_large_image"]', visible: false),
        have_selector('meta[name="twitter:site"][content="フリーコンサルタント.jp"]', visible: false),
        have_selector('meta[name="twitter:title"]', visible: false) do |tag|
          tag['content'] == '【フリーコンサルタント.jp】高年収／高単価の戦略・PMO・IT案件に特化したマッチングエージェント'
        end,
        have_selector('meta[name="twitter:description"]', visible: false) do |tag|
          tag['content'] == 'フリーコンサルタント.jpは、PMO案件をはじめPM,SAP,IT,戦略,新規事業,業務改革等の高額プロジェクト紹介。フリーランス人材のためのコンサルタント登録・募集、人材派遣のマッチングサービス。'
        end
      ].inject(:and)
    end
  end
end
