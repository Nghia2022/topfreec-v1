# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mypage::Fc::Settings', type: :system do
  let(:sf_account) { FactoryBot.build_stubbed(:sf_account_fc) }
  let(:sf_contact) { FactoryBot.build_stubbed(:sf_contact, :fc) }
  let(:sf_content_document) { FactoryBot.build(:sf_content_document) }

  describe '設定画面' do
    before do
      allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
      allow_any_instance_of(Account).to receive(:to_sobject).and_return(sf_account)
      allow(Salesforce::ContentDocument).to receive(:find_by).and_return(sf_content_document)
      sign_in(fc_user)
    end

    let(:fc_user) { FactoryBot.create(:fc_user, :fc_company, :activated) }

    it do
      visit mypage_fc_settings_path

      expect(page).to have_content('ログイン設定')
        .and have_content('基本情報')
        .and have_content('希望条件')
        .and have_content('案件紹介リクエスト')
        .and have_content('資格・レジュメ')
        .and have_content('サービス利用状況')

      page.find('[data-target=form-request]').click

      within '.modal-panel' do
        expect(page).to have_content('案件リクエストを設定してください')
        fill_in 'project_request[start_timing]', with: Date.current.next_day(10).to_s
        fill_in 'project_request[reward_desired]', with: '100'
        fill_in 'project_request[reward_min]', with: '50'
        choose '週5日'
        click_on '保存する'
      end

      page.find('[data-target=form-request]').click

      within '.modal-panel' do
        expect(page).to have_content('案件リクエストを設定してください')
          .and have_content('100')
          .and have_no_content('100.0')
      end
    end

    # TODO: #3353 Flipperの分岐を無くして1つにする
    describe 'data-target=form-requirement のモーダル' do
      let(:fc_user) { FactoryBot.create(:fc_user, :fc_company, :activated) }

      context 'Featureフラグの :new_work_category が「有効」な場合' do
        before do
          Flipper.enable :new_work_category
        end

        it do
          visit mypage_fc_settings_path
          page.find('[data-target=form-requirement]', match: :first).click
          within '.modal-panel' do
            expect(page).to have_content('可能な就業形態')
              .and have_content('企業規模')
              .and have_content('希望稼働エリア')
              .and have_no_content('得意領域')
              .and have_no_content('希望領域')
          end
        end
      end

      context 'Featureフラグの :new_work_category が「無効」な場合' do
        it do
          visit mypage_fc_settings_path
          page.find('[data-target=form-requirement]', match: :first).click
          within '.modal-panel' do
            expect(page).to have_content('可能な就業形態')
              .and have_content('企業規模')
              .and have_content('希望稼働エリア')
              .and have_content('得意領域')
              .and have_content('興味がある')
          end
        end
      end
    end
  end
end
