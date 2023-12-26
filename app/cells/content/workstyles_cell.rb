# frozen_string_literal: true

class Content::WorkstylesCell < ApplicationCell
  cache :show do
    model.cache_key_with_version
  end

  cache :latest_workstyle do
    model.cache_key_with_version
  end

  def show
    model.preload_meta_images

    cell(Content::WorkstyleCell, collection: model.decorate).call(:show)
  end

  def latest_workstyle
    model.preload_meta_images

    render
  end
end
