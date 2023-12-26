# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ClientUsers::Sessions', type: :system do
  context 'login' do
    let(:client_user) { FactoryBot.create(:client_user, :with_contact) }

    describe 'without remember_me' do
      it do
        visit new_client_user_session_path
        fill_in 'client_user[email]', with: client_user.email
        fill_in 'client_user[password]', with: client_user.password
        click_button '同意してログイン'

        expect(page.current_url).to eq mypage_client_directions_url

        remember_me_token = page.driver.browser.rack_mock_session.cookie_jar['remember_client_user_token']

        in_browser('another_session') do
          page.driver.browser.rack_mock_session.cookie_jar['remember_client_user_token'] = remember_me_token

          visit new_client_user_session_path

          expect(page.current_url).to eq new_client_user_session_url
        end
      end
    end

    describe 'with remember_me' do
      it do
        visit new_client_user_session_path
        fill_in 'client_user[email]', with: client_user.email
        fill_in 'client_user[password]', with: client_user.password
        check 'client_user[remember_me]'
        click_button '同意してログイン'

        expect(page.current_url).to eq mypage_client_directions_url

        remember_me_token = page.driver.browser.rack_mock_session.cookie_jar['remember_client_user_token']

        in_browser('another_session') do
          page.driver.browser.rack_mock_session.cookie_jar['remember_client_user_token'] = remember_me_token

          visit new_client_user_session_path

          expect(page.current_url).to eq mypage_client_directions_url
        end
      end
    end

    context 'アカウントが凍結されている場合' do
      before do
        client_user.update(locked_at: Time.current, failed_attempts: 10)
      end

      it do
        visit new_client_user_session_path
        fill_in 'client_user[email]', with: client_user.email
        fill_in 'client_user[password]', with: client_user.password
        click_button '同意してログイン'

        expect(page.current_path).to eq new_client_user_session_path
        within '.form-error' do
          expect(page).to have_content 'メールアドレスかパスワードが間違っています'
        end
      end
    end

    context 'アカウントが凍結後に時間経過した場合' do
      before do
        client_user.update(locked_at: 30.minutes.ago, failed_attempts: 10)
      end

      it do
        visit new_client_user_session_path
        fill_in 'client_user[email]', with: client_user.email
        fill_in 'client_user[password]', with: client_user.password
        click_button '同意してログイン'

        expect(page.current_path).to eq mypage_client_directions_path
      end
    end
  end

  describe 'timeout' do
    let(:client_user) { FactoryBot.create(:client_user, :with_contact) }

    it do
      aggregate_failures do
        sign_in(client_user)
        visit mypage_client_directions_url

        expect(page.current_url).to eq mypage_client_directions_url

        travel_to 3.hours.from_now do
          visit mypage_client_directions_url

          expect(page.current_url).to eq new_client_user_session_url
          expect(page).to have_content('セッションがタイムアウトしました。もう一度ログインしてください。')
        end
      end
    end
  end

  describe 'password_expired' do
    let(:client_user) { FactoryBot.create(:client_user, password_changed_at: nil) }

    before do
      client_user.need_change_password!
    end

    it do
      aggregate_failures do
        visit new_client_user_session_path
        fill_in 'client_user[email]', with: client_user.email
        fill_in 'client_user[password]', with: client_user.password
        click_button '同意してログイン'

        expect(page.current_url).to eq client_user_password_expired_url
      end
    end
  end
end
