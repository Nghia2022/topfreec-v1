# frozen_string_literal: true

class Content::ColumnsCell < ApplicationCell
  cache :show do
    model.cache_key_with_version
  end

  cache :latest_column do
    model.cache_key_with_version
  end

  def show
    model.preload_thumbnails

    cell(Content::ColumnCell, collection: model.decorate).call(:show)
  end

  def latest_column
    model.preload_thumbnails

    render
  end
end
