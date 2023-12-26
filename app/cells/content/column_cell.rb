# frozen_string_literal: true

class Content::ColumnCell < ApplicationCell
  property :post_title
  property :facebook_share_url
  property :twitter_share_url
  property :hatena_share_url
  property :thumbnail
  property :column_date

  cache :detail do
    model.cache_key_with_version
  end

  def show
    render
  end

  def detail
    render
  end

  def latest_column
    render
  end

  def tags
    render
  end

  def recommended
    render
  end

  def column_tags_name
    model.decorate.column_tags.join(', ')
  end

  def detail_path
    content_column_path(model)
  end

  def paragraph_body
    auto_paragraph(model.paragraph_body)
  end
end
