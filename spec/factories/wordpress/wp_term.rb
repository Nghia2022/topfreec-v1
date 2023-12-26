# frozen_string_literal: true

FactoryBot.define do
  factory :wp_term, class: 'Wordpress::WpTerm' do
    name { '企業系・独立系のノウハウ・ドウハウ' }
  end
end
