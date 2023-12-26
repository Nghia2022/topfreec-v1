# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mypage::Fc::Registrations', type: :system do
  let(:sf_account_fc) { FactoryBot.build(:sf_account_fc) }
  let(:sf_contact) { FactoryBot.build_stubbed(:sf_contact, :fc) }
  let(:fc_user) { FactoryBot.create(:fc_user, :activated, contact_trait: [:valid_data_for_register], registration_completed_at: nil) }

  describe 'visit /mypage/fc/register' do
    before do
      FeatureSwitch.enable :temporary_disabled
      stub_salesforce_request
      allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
      allow_any_instance_of(Account).to receive(:to_sobject).and_return(sf_account_fc)
      allow_any_instance_of(Restforce::Concerns::API).to receive(:select)
      sign_in(fc_user)
    end

    # TODO: #3353 Flipperの分岐を無くして1つにする
    context 'Featureフラグの :new_work_category が「有効」な場合' do
      before do
        Flipper.enable :new_work_category
      end

      it 'should be set default values in input fields' do
        visit '/mypage/fc/register'
        expect(page)
          .to have_field('fc_user_zipcode', with: '1500012')
          .and have_select('fc_user_prefecture', selected: '東京都')
          .and have_field('fc_user_city', with: '渋谷区広尾１丁目１−３９')
          .and have_field('fc_user_building', with: '恵比寿プライムスクエアタワー4F')
          .and have_field('fc_user_start_timing', with: Date.current >> 1)
          .and have_checked_field('IT・PM')
          .and have_checked_field('IT・PMO')
          .and have_checked_field('事業開発（企画）')
          .and have_select('fc_user_work_location1', selected: '青森県')
          .and have_select('fc_user_work_location2', selected: '沖縄県')
          .and have_select('fc_user_work_location3', selected: '長野県')
          .and have_field('fc_user_reward_min', with: '300')
          .and have_checked_field('週4日')
          .and have_checked_field('完全出社')
          .and have_checked_field('完全リモート')
          .and have_field('fc_user_requests', with: 'メモ')
      end
    end

    context 'Featureフラグの :new_work_category が「無効」な場合' do
      it 'should be set default values in input fields' do
        visit '/mypage/fc/register'
        expect(page)
          .to have_field('fc_user_zipcode', with: '1500012')
          .and have_select('fc_user_prefecture', selected: '東京都')
          .and have_field('fc_user_city', with: '渋谷区広尾１丁目１−３９')
          .and have_field('fc_user_building', with: '恵比寿プライムスクエアタワー4F')
          .and have_field('fc_user_start_timing', with: Date.current >> 1)
          .and have_checked_field('PM/PMO')
          .and have_checked_field('人事/組織設計')
          .and have_checked_field('新規事業/IPO')
          .and have_checked_field('営業')
          .and have_checked_field('セキュリティ')
          .and have_checked_field('中小')
          .and have_checked_field('ベンチャー')
          .and have_select('fc_user_work_location1', selected: '青森県')
          .and have_select('fc_user_work_location2', selected: '沖縄県')
          .and have_select('fc_user_work_location3', selected: '長野県')
          .and have_field('fc_user_reward_min', with: '300')
          .and have_checked_field('週4日')
          .and have_checked_field('完全出社')
          .and have_checked_field('完全リモート')
          .and have_field('fc_user_requests', with: 'メモ')
      end
    end

    scenario '本登録前はチュートリアルは表示しない' do
      visit '/mypage/fc/register'
      expect(page).not_to have_content('チュートリアル')
    end

    scenario '本登録を終えてダッシュボードに移動した後、一度だけチュートリアルを表示する' do
      visit '/mypage/fc/register'
      click_button '会員登録する'
      expect(page).to have_content('チュートリアル')
      visit '/'
      expect(page).not_to have_content('チュートリアル')
    end
  end
end
