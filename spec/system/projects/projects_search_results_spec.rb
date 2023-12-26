# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Projects::SearchResults', type: :system, js: true do
  describe 'pagerizer' do
    let_it_be(:projects_count) { 50 }
    let_it_be(:projects) { FactoryBot.create_list(:project, projects_count) }

    it do
      visit projects_url

      expect(page).to have_link(class: 'next page-numbers', href: '/project?page=2')
      .and have_selector(:testid, 'project/card', count: 25, visible: false)
    end

    context 'when click next link' do
      it do
        visit projects_url

        expect(page).to have_link(class: 'next page-numbers', href: '/project?page=2')

        click_link(class: 'next page-numbers')

        expect(page.current_url).to eq("#{projects_url}?page=2")
      end
    end
  end
end
