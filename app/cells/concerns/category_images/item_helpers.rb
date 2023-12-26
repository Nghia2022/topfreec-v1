# frozen_string_literal: true

module CategoryImages::ItemHelpers
  extend ActiveSupport::Concern

  included do
    alias_method :project, :model
  end

  def category_image
    project.category_image(image_index)
  end

  def image_index
    options.fetch(:image_index, 1)
  end
end
