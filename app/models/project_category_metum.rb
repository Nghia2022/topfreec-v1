# frozen_string_literal: true

class ProjectCategoryMetum < ApplicationRecord
  belongs_to :work_category, foreign_key: :work_category_main, primary_key: :main_category, inverse_of: :project_category_meta
  belongs_to :project_experience_category, class_name: 'Project::ExperienceCategory', foreign_key: :work_category_main, primary_key: :value, inverse_of: :project_category_metum

  # MetaTags.config.title_limit = 70
  # site: 'フリーコンサルタント.jp' = 13
  # separator: ' | ' = 3
  # 70 - 13 - 3 = 54
  TITLE_LIMIT = 54
  I18N_SCOPE = 'activerecord.project_category_metum.defaults'

  validates :slug, presence: true, uniqueness: true
  validates :title, length: { maximum: TITLE_LIMIT }
  validates :description, length: { maximum: MetaTags.config.description_limit }
  validates :work_category_main,
            presence:  true,
            inclusion: {
              in: ->(_) { WorkCategory.pluck(:main_category) }
            }
  validates :work_category_sub,
            inclusion: {
              in:          ->(_) { WorkCategory.pluck(:sub_category).flatten },
              allow_blank: true
            }

  def projects
    Project.with_main_category(ActiveRecord::Base.sanitize_sql_like(work_category_main))
           .with_sub_category(ActiveRecord::Base.sanitize_sql_like(work_category_sub.to_s))
  end

  def category_name
    main_category? ? work_category_main : work_category_sub
  end

  class Null < ProjectCategoryMetum
    attribute :title, default: -> { I18n.t(:title, scope: I18N_SCOPE) }
    attribute :description, default: -> { I18n.t(:description, scope: I18N_SCOPE) }
    attribute :keywords, default: -> { I18n.t(:keywords, scope: I18N_SCOPE) }
  end

  class << self
    def fetch_by_or_null(target_attributes)
      find_by(target_attributes) || Null.new
    end
  end

  private

  def main_category?
    !work_category_sub?
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
