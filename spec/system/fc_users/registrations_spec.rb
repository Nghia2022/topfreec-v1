# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'FcUsers::Registrations', type: :system do
  describe 'FC会員登録' do
    it do
      visit new_fc_user_registration_path

      expect(page).to have_content('勤務可能地域').and have_content('※半角数字 / ハイフン(-)なし')
    end
  end

  describe '利用規約' do
    it do
      visit new_fc_user_registration_path

      expect(page).to have_content('●サービス利用規約')
    end
  end
end
