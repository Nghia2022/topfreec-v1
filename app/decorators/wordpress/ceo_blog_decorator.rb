# frozen_string_literal: true

class Wordpress::CeoBlogDecorator < Wordpress::WpPostDecorator
  delegate_all

  def blog_date
    I18n.l fix_time_zone(object.post_date), format: :date_with_day_half
  end

  def blog_modified
    I18n.l fix_time_zone(object.post_modified), format: :date_with_day_half
  end

  def thumbnail
    WordpressImageReplacer.replace(object.thumbnail.__sync&.guid)
  end

  def url
    h.content_blog_url(object)
  end

  def meta_description
    object.post_content
  end

  def og_description
    normalize_description(post_content)
  end

  def og_title(site_name)
    normalize_description("#{object.post_title}｜代表ブログ｜#{site_name}")
  end

  def post_content
    WordpressImageReplacer.replace(object.post_content)
  end
end
