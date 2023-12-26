# frozen_string_literal: true

class Admin::Projects::ExperienceCategoriesController < Admin::ApplicationController
  def index; end

  private

  def experience_categories
    @experience_categories ||= Admin::Projects::ExperienceCategoryDecorator.decorate_collection(Project::ExperienceCategory.all)
  end

  helper_method :experience_categories
end
