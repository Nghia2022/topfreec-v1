# frozen_string_literal: true

FactoryBot.define do
  factory :workstyle, class: 'Wordpress::Workstyle' do
    post_name { 'workstyle1' }
    post_title { 'Workstyle 1' }
    post_date { 1.day.ago }
    post_modified { Time.current }
  end
end
