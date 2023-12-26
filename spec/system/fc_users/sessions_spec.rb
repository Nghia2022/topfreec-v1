# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'FcUsers::Sessions', type: :system do
  before do
    driven_by(:rack_test)
    uri = URI.parse(Capybara.app_host)
    Rails.application.routes.default_url_options[:host] = "#{uri.host}:#{uri.port}"
  end

  context 'login' do
    let(:fc_user) { FactoryBot.create(:fc_user, :activated) }
    let(:sf_contact) { FactoryBot.build_stubbed(:sf_contact, :fc) }
    let(:sf_account) { FactoryBot.build_stubbed(:sf_account_fc) }

    before do
      allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
      allow_any_instance_of(Account).to receive(:to_sobject).and_return(sf_account)
    end

    describe 'without remember_me' do
      it do
        visit new_fc_user_session_path
        fill_in 'fc_user[email]', with: fc_user.email
        fill_in 'fc_user[password]', with: fc_user.password
        click_button '同意してログイン'

        expect(page.current_url).to eq mypage_fc_root_url

        remember_me_token = page.driver.browser.rack_mock_session.cookie_jar['remember_fc_user_token']

        in_browser('another_session') do
          page.driver.browser.rack_mock_session.cookie_jar['remember_fc_user_token'] = remember_me_token

          visit new_fc_user_session_path

          expect(page.current_url).to eq new_fc_user_session_url
        end
      end
    end

    describe 'with remember_me' do
      it do
        visit new_fc_user_session_path
        fill_in 'fc_user[email]', with: fc_user.email
        fill_in 'fc_user[password]', with: fc_user.password
        check 'fc_user[remember_me]'
        click_button '同意してログイン'

        expect(page.current_url).to eq mypage_fc_root_url

        remember_me_token = page.driver.browser.rack_mock_session.cookie_jar['remember_fc_user_token']

        in_browser('another_session') do
          page.driver.browser.rack_mock_session.cookie_jar['remember_fc_user_token'] = remember_me_token

          visit new_fc_user_session_path

          expect(page.current_url).to eq mypage_fc_root_url
        end
      end
    end

    describe '会員登録ページからログインする' do
      it 'ログイン後にマイページに遷移する' do
        visit register_path
        click_link('こちら')

        fill_in 'fc_user[email]', with: fc_user.email
        fill_in 'fc_user[password]', with: fc_user.password
        click_button '同意してログイン'

        expect(page.current_path).to eq mypage_fc_root_path
      end
    end

    describe '案件一覧ページからログインする' do
      it 'ログイン後に案件一覧ページに遷移する' do
        visit projects_path
        click_link('ログイン')

        fill_in 'fc_user[email]', with: fc_user.email
        fill_in 'fc_user[password]', with: fc_user.password
        click_button '同意してログイン'

        expect(page.current_path).to eq projects_path
      end
    end

    describe '案件詳細ページからログインする' do
      let(:project) { FactoryBot.create(:project) }

      it 'ログイン後に案件詳細ページに遷移する' do
        visit project_path(project)
        click_link('ログインして確認')

        fill_in 'fc_user[email]', with: fc_user.email
        fill_in 'fc_user[password]', with: fc_user.password
        click_button '同意してログイン'

        expect(page.current_path).to eq project_path(project)
      end
    end

    context 'アカウントが凍結されている場合' do
      before do
        fc_user.update(locked_at: Time.current, failed_attempts: 10)
      end

      it do
        visit new_fc_user_session_path
        fill_in 'fc_user[email]', with: fc_user.email
        fill_in 'fc_user[password]', with: fc_user.password
        click_button '同意してログイン'

        expect(page.current_path).to eq new_fc_user_session_path
        within '.form-error' do
          expect(page).to have_content 'メールアドレスかパスワードが間違っています'
        end
      end
    end

    context 'アカウントが凍結後に時間経過した場合' do
      before do
        fc_user.update(locked_at: 30.minutes.ago, failed_attempts: 10)
      end

      it do
        visit new_fc_user_session_path
        fill_in 'fc_user[email]', with: fc_user.email
        fill_in 'fc_user[password]', with: fc_user.password
        click_button '同意してログイン'

        expect(page.current_path).to eq mypage_fc_root_path
      end
    end
  end

  describe 'timeout' do
    let(:fc_user) { FactoryBot.create(:fc_user, :activated) }
    let(:sf_contact) { FactoryBot.build_stubbed(:sf_contact, :fc) }
    let(:sf_account) { FactoryBot.build_stubbed(:sf_account_fc) }

    before do
      allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
      allow_any_instance_of(Account).to receive(:to_sobject).and_return(sf_account)
    end

    it do
      aggregate_failures do
        sign_in(fc_user)
        visit mypage_fc_root_url

        expect(page.current_url).to eq mypage_fc_root_url

        travel_to 3.hours.from_now do
          visit mypage_fc_root_url

          expect(page.current_url).to eq new_fc_user_session_url
          expect(page).to have_content('セッションがタイムアウトしました。もう一度ログインしてください。')
        end
      end
    end
  end

  describe 'password_expired' do
    let(:fc_user) { FactoryBot.create(:fc_user, :activated, password_changed_at: nil) }
    let(:sf_contact) { FactoryBot.build_stubbed(:sf_contact, :fc) }
    let(:sf_account) { FactoryBot.build_stubbed(:sf_account_fc) }

    before do
      fc_user.need_change_password!
      allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
      allow_any_instance_of(Account).to receive(:to_sobject).and_return(sf_account)
    end

    it do
      aggregate_failures do
        visit new_fc_user_session_path
        fill_in 'fc_user[email]', with: fc_user.email
        fill_in 'fc_user[password]', with: fc_user.password
        click_button '同意してログイン'

        expect(page.current_path).to eq fc_user_password_expired_path
      end
    end
  end

  describe "'利用規約'をクリックする" do
    it '法人向け利用規約ページに遷移する' do
      visit new_fc_user_session_path

      click_link '利用規約', href: terms_page_path

      expect(page).to have_current_path(terms_page_url)
        .and have_title('サービス利用規約｜コンサル案件紹介の契約詳細')
    end
  end
end
