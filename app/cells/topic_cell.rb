# frozen_string_literal: true

class TopicCell < ApplicationCell
  property :total_count

  attr_reader :enable_pagination

  cache :show do
    cache_keys
  end

  cache :show_without_pagination do
    cache_keys
  end

  def show
    @enable_pagination = true
    render view: :show, layout: 'layout'
  end

  def show_without_pagination
    @enable_pagination = false
    render :show
  end

  private

  def cache_keys
    [model.cache_key(:post_date), model.cache_version(:post_date)]
  end
end
