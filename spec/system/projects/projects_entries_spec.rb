# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Projects::Entries', type: :system, js: true, retry: 3, skip: 'Temporary skippped, broken on CircleCI' do
  describe 'entry' do
    let(:project) { FactoryBot.create(:project, :with_publish_datetime) }

    shared_context 'signed in as fc' do
      let(:fc_user) { FactoryBot.create(:fc_user, :activated) }

      let(:sf_account) { FactoryBot.build(:sf_account_fc) }
      let(:sf_contact) { FactoryBot.build(:sf_contact, :fc) }

      before do
        allow_any_instance_of(Account).to receive(:to_sobject).and_return(sf_account)
        allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
        sign_in fc_user
      end
    end

    context 'without variant' do
      include_context 'signed in as fc'

      it '応募ボタンを押すと、応募完了画面に遷移する' do
        visit project_path(project)
        resize_browser_size_to_pc
        page.execute_script 'window.scrollBy(0,100)'

        within '.btn-layout-fixed' do
          expect(page).to have_button('この案件に応募する')

          click_on('この案件に応募する')
        end

        page.execute_script 'window.scrollBy(0,100)'
        within '.modal-panel' do
          expect(page).to have_button('応募する')

          fill_in('matching[start_timing]', with: Date.current.to_s)
          fill_in('matching[reward_min]', with: 50)
          fill_in('matching[reward_desired]', with: 100)
          choose '週5日(100%)'

          click_on '応募する'
        end
        wait_for_ajax_finished

        expect(page.current_url).to eq thanks_entry_url
      end
    end

    context 'when fc already entried to the project' do
      include_context 'signed in as fc'

      let!(:existing_matching) { FactoryBot.create(:matching, project:, account: fc_user.account) }

      it do
        visit project_path(project)
        page.execute_script 'window.scrollBy(0,100)'

        within '.btn-layout-fixed' do
          expect(page).to have_button('応募済み', disabled: true)
        end
      end
    end

    context 'when fc is not signed in' do
      before do
        allow_any_instance_of(Devise::Controllers::Helpers).to receive(:fc_user_signed_in?).and_return(false)
      end

      it '応募ボタンを押すとログイン画面に遷移する' do
        visit project_path(project)
        page.execute_script 'window.scrollBy(0,100)'

        expect(page).to have_link('この案件に応募する')

        click_link('この案件に応募する')

        expect(page.current_url).to eq new_fc_user_session_url
      end
    end

    context 'when accessed from new_fc_user_session_path' do
      context 'when fc already signed in' do
        let(:fc_user) { FactoryBot.create(:fc_user, :activated) }
        let(:sf_account) { FactoryBot.build(:sf_account_fc) }
        let(:sf_contact) { FactoryBot.build(:sf_contact, :fc) }

        before do
          allow_any_instance_of(Account).to receive(:to_sobject).and_return(sf_account)
          allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
        end

        it '応募ボタンが自動でクリックされる' do
          visit project_path(project)
          page.execute_script 'window.scrollBy(0,100)'

          within '.btn-layout-fixed' do
            expect(page).to have_link('この案件に応募する')

            click_link('この案件に応募する')
          end

          expect(page.current_url).to eq new_fc_user_session_url

          fill_in 'fc_user[email]', with: fc_user.email
          fill_in 'fc_user[password]', with: fc_user.password
          click_button '同意してログイン'
          page.execute_script 'window.scrollBy(0,100)'

          expect(page.current_url).to eq project_url(project)
        end
      end

      context 'when fc is not signed in' do
        before do
          allow_any_instance_of(Devise::Controllers::Helpers).to receive(:fc_user_signed_in?).and_return(false)
        end

        it '検索フォームが正常に初期化される' do
          visit project_path(project)
          wait_for_ajax_finished
          page.execute_script 'window.scrollBy(0,100)'

          within '.btn-layout-fixed' do
            expect(page).to have_link('この案件に応募する')

            click_link('この案件に応募する')
          end
          expect(page.current_url).to eq new_fc_user_session_url

          find('#menu02').click
          click_on('案件を見つける')
          click_link('すべての案件から探す')
          expect(page.current_url).to eq projects_url

          page.execute_script 'window.scrollBy(0,100)'
          expect(page).to have_no_selector('#btn-entry')
        end
      end
    end
  end
end
