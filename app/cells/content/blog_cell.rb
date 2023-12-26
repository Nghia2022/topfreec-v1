# frozen_string_literal: true

class Content::BlogCell < ApplicationCell
  property :post_title
  property :thumbnail
  property :facebook_share_url
  property :twitter_share_url
  property :hatena_share_url
  property :blog_date
  property :blog_modified

  cache :detail do
    model.cache_key_with_version
  end

  def show
    render
  end

  def detail
    render
  end

  def latest_blog
    render
  end

  def detail_path
    content_blog_path(model)
  end

  def post_content
    auto_paragraph(model.post_content)
  end
end
