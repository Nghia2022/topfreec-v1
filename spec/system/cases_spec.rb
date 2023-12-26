# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Cases', type: :system do
  describe '個人情報の取扱いについて' do
    it do
      visit new_case_path

      find_link '個人情報の取扱いについて', href: mirai_works_privacy_entry_url, target: '_blank'
    end
  end
end
