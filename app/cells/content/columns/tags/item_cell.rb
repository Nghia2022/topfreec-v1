# frozen_string_literal: true

class Content::Columns::Tags::ItemCell < ApplicationCell
  property :name
  property :slug

  def show
    render
  end

  private

  def url
    content_columns_path(tag: slug)
  end

  def selected?
    options[:selected] == model.slug
  end

  def html_class
    class_names('btn  bs-small', 'btn-theme-02': selected?, 'btn-theme-02-outline': !selected?)
  end
end
