# frozen_string_literal: true

class Fc::Recommended::ProjectsQuery
  include Query

  def initialize(contact:, relation: Project.published)
    @relation = relation
    @contact = contact
  end

  attr_reader :relation, :contact

  def call
    return new_arrival_projects if contact.blank?

    selected_projects.presence || new_arrival_projects
  end

  def selected_projects
    selected_projects_with_all
  end

  def selected_projects_with_all
    @selected_projects_with_all ||=
      relation
      .with_experience_categories(contact.works_to_recommends)
      .distinct
  end

  def new_arrival_projects
    @new_arrival_projects ||= relation.published.new_arrival
  end

  def self.display_limit
    10
  end
end
