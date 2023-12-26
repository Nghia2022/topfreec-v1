# frozen_string_literal: true

class Projects::RelatedProjectsQuery
  include Query

  def initialize(relation:, project:, display_limit:)
    @relation = relation
    @project = project
    @display_limit = display_limit
  end

  attr_reader :relation, :project, :display_limit

  def call
    return selected_projects_with_any if selected_projects_with_all_less_than_display_limit?

    selected_projects_with_all
  end

  def selected_projects_with_all
    @selected_projects_with_all ||=
      relation
      .with_experience_categories(project.experiencecatergory__c)
      .distinct
  end

  def selected_projects_with_any
    @selected_projects_with_any ||=
      relation
      .merge(
        [
          project_category.presence && relation.with_experience_categories(project_category)
        ].compact.inject(:or) || Project.all
      )
  end

  private

  def selected_projects_with_all_less_than_display_limit?
    selected_projects_with_all.size < display_limit
  end

  def project_category
    project.experiencecatergory__c
  end
end
