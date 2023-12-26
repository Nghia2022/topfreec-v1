# frozen_string_literal: true

class Projects::ListCell < ApplicationCell
  include CategoryImages::ListHelpers

  def show
    render_items_with_image_index(ProjectCell, :card)
  end
end
