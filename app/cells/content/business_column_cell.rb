# frozen_string_literal: true

class Content::BusinessColumnCell < ApplicationCell
  property :post_title
  property :facebook_share_url
  property :twitter_share_url
  property :hatena_share_url
  property :thumbnail

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

  def post_content
    auto_paragraph(model.post_content)
  end

  def column_date
    I18n.ln(model.post_date, format: :date_with_day_half)
  end

  def column_tags_name
    model.decorate.column_tags.join(', ')
  end

  def detail_path
    corp_business_column_path(model)
  end
end
