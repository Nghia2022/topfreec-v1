# frozen_string_literal: true

class Wordpress::ColumnDecorator < Wordpress::WpPostDecorator
  delegate_all

  def column_date
    I18n.l fix_time_zone(object.post_date), format: :date_with_day_half
  end

  def column_modified
    I18n.l fix_time_zone(object.post_modified), format: :date_with_day_half
  end

  def url
    h.content_column_url(object)
  end

  def column_tags
    object.terms.pluck(:name)
  end

  def paragraph_body
    WordpressImageReplacer.replace(postmeta('column-paragraph-body'))
  end

  def thumbnail
    WordpressImageReplacer.replace(object.thumbnail.__sync&.guid)
  end

  def meta_description
    postmeta('_aioseop_description')
  end

  def og_description
    normalize_description(paragraph_body)
  end

  def og_title
    normalize_description(object.post_title)
  end
end
