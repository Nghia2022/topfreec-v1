# frozen_string_literal: true

class Content::ListCell < ApplicationCell
  property :prev_content
  property :next_content

  def show
    slider
  end

  private

  def index_path
    url_for(model.class)
  end

  def prev_path
    url_for(prev_content)
  end

  def next_path
    url_for(next_content)
  end

  def prev_slider
    render if prev?
  end

  def slider
    render
  end

  def next_slider
    render if next?
  end

  def prev?
    prev_content.present?
  end

  def next?
    next_content.present?
  end
end
