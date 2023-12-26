# frozen_string_literal: true

FactoryBot.define do
  factory :project_category_metum do
    slug { 'project-management' }
    work_category_main { 'プロジェクト管理' }
  end

  trait :work_sub_category do
    work_category_sub { 'PM' }
  end
end

# == Schema Information
#
# Table name: project_category_meta
#
#  id                 :bigint           not null, primary key
#  description        :text
#  keywords           :string
#  slug               :string           not null
#  title              :string
#  work_category_main :string           not null
#  work_category_sub  :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_project_category_meta_on_slug  (slug) UNIQUE
#
