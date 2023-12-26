# frozen_string_literal: true

class Content::WorkstyleCell < ApplicationCell
  property :post_title
  property :facebook_share_url
  property :twitter_share_url
  property :hatena_share_url
  property :consultant_description
  property :consultant_name
  property :consultant_kana
  property :consultant_meta
  property :consultant_image
  property :subtitle
  property :paragraph_body
  property :paragraph_image
  property :workstyle_date
  property :workstyle_modified

  cache :detail do
    model.cache_key_with_version
  end

  def show
    render
  end

  def detail
    render
  end

  def section(index)
    yield if subtitle(index).present?
  end

  def latest_workstyle
    render
  end

  def detail_path
    content_workstyle_path(model)
  end

  def excerpt
    text_format(model.excerpt)
  end
end
