# frozen_string_literal: true

class ProjectDailyPageView < ApplicationRecord
  belongs_to :project

  include Materializable

  self.primary_key = :project_id

  scope :popularity, -> { order(pv: :desc) }
end

# == Schema Information
#
# Table name: project_daily_page_views
#
#  pv         :bigint
#  project_id :integer          primary key
#
# Indexes
#
#  index_project_daily_page_views_on_project_id  (project_id) UNIQUE
#  index_project_daily_page_views_on_pv          (pv)
#
