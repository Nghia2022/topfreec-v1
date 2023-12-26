# frozen_string_literal: true

# :reek:TooManyMethods

class Wordpress::WorkstyleDecorator < Wordpress::WpPostDecorator
  delegate_all

  def workstyle_date
    I18n.l fix_time_zone(object.post_date), format: :date_with_day_half
  end

  def workstyle_modified
    I18n.l fix_time_zone(object.post_modified), format: :date_with_day_half
  end

  def url
    h.content_workstyle_url(object)
  end

  def excerpt
    postmeta('article-excerpt')
  end

  # :nocov:
  def thumbnail
    WordpressImageReplacer.replace(object.thumbnail.__sync&.guid)
  end
  # :nocov:

  def consultant_description
    postmeta('consultant-description')
  end

  def consultant_name
    postmeta('consultant-name')
  end

  def consultant_kana
    postmeta('consultant-kana')
  end

  def consultant_meta
    postmeta('consultant-meta')
  end

  def consultant_image
    meta_image('consultant-image')
  end

  def subtitle(index)
    postmeta("subtitle-mid#{index}")
  end

  # :nocov:
  def paragraph_body(index)
    WordpressImageReplacer.replace(postmeta("paragraph-body#{index}"))
  end
  # :nocov:

  # :nocov:
  def paragraph_image(index)
    meta_image("paragraph-image#{index}")
  end
  # :nocov:

  def meta_description
    excerpt
  end

  def og_description
    normalize_description("#{consultant_name}（#{consultant_kana}）\n#{excerpt}")
  end

  def og_title
    normalize_description("#{object.post_title}｜プロフェッショナリズム")
  end
end
