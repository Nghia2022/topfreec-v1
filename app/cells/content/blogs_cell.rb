# frozen_string_literal: true

class Content::BlogsCell < ApplicationCell
  cache :show do
    model.cache_key_with_version
  end

  cache :latest_blog do
    model.cache_key_with_version
  end

  def show
    model.preload_thumbnails

    cell(Content::BlogCell, collection: model.decorate).call(:show)
  end

  def latest_blog
    model.preload_thumbnails

    render
  end
end
