# frozen_string_literal: true

module CategoryImages::ListHelpers
  extend ActiveSupport::Concern

  MAX_IMAGE_INDEX = 4

  included do
    alias_method :projects, :model
  end

  def render_items_with_image_index(render_cell, render_method)
    generator = (1..MAX_IMAGE_INDEX).cycle

    projects_with_blank.each_cons(2).map do |prev, current|
      generator.rewind if prev.primary_category != current.primary_category

      cell(render_cell, current, image_index: generator.next).call(render_method)
    end.join
  end

  def projects_with_blank
    [Project.new.decorate] + projects
  end
end
