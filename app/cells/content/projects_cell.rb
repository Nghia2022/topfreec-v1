# frozen_string_literal: true

class Content::ProjectsCell < ApplicationCell
  cache :show do
    model.cache_key_with_version
  end

  def show
    render layout: 'layout'
  end
end
