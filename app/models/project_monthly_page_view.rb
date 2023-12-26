# frozen_string_literal: true

class ProjectMonthlyPageView < ApplicationRecord
  belongs_to :project

  include Materializable

  self.primary_key = :project_id
end

# == Schema Information
#
# Table name: project_monthly_page_views
#
#  pv         :bigint
#  project_id :integer          primary key
#
# Indexes
#
#  index_project_monthly_page_views_on_project_id  (project_id) UNIQUE
#  index_project_monthly_page_views_on_pv          (pv)
#
