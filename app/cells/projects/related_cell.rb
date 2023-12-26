# frozen_string_literal: true

class Projects::RelatedCell < ApplicationCell
  include CategoryImages::ListHelpers
  include CategoryImages::ItemHelpers
  include CompensationFormattable::V2022

  property :project_name
  property :compensation_min
  property :compensation_max
  property :client_category_name
  property :work_location
  property :work_options

  def detail
    render
  end

  def detail_related
    render
  end

  def thanks
    render
  end

  def thanks_related
    render
  end

  private

  def experience_categories
    model.experience_categories.join(', ')
  end

  def list_detail_related
    render_items_with_image_index(Projects::RelatedCell, :detail_related)
  end

  def list_thanks_related
    render_items_with_image_index(Projects::RelatedCell, :thanks_related)
  end
end
