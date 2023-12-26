# frozen_string_literal: true

class Projects::ExperienceCategoriesCell < ApplicationCell
  def show
    render layout: :layout
  end

  alias experience_categories model
end
