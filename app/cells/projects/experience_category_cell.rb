# frozen_string_literal: true

class Projects::ExperienceCategoryCell < ApplicationCell
  include CloudinaryHelper

  def show
    render
  end

  private

  def category_image_url
    cl_image_path("categories/#{model.slug}/menu.png", transformation: 'categories')
  end

  def category_name
    model.value
  end

  def slug
    model.project_category_metum.slug
  end
end
