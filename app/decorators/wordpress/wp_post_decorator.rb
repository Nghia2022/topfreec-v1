# frozen_string_literal: true

class Wordpress::WpPostDecorator < Draper::Decorator
  delegate_all

  def facebook_share_url
    "http://www.facebook.com/share.php?u=#{CGI.escape(url)}"
  end

  def twitter_share_url
    "https://twitter.com/share?url=#{CGI.escape(url)}"
  end

  def hatena_share_url
    "http://b.hatena.ne.jp/add?mode=confirm&url=#{CGI.escape(url)}"
  end

  def url; end

  def meta_keywords
    postmeta('_aioseop_keywords')
  end

  class << self
    def collection_decorator_class
      PaginatingDecorator
    end
  end

  protected

  def meta_image(key)
    WordpressImageReplacer.replace(object.meta_images.__sync&.find { |attachment| attachment.meta_key == key }&.guid)
  end

  def postmeta(key)
    postmetas.find { |pm| pm.meta_key == key }&.meta_value
  end

  def postmetas
    @postmetas ||= object.wp_postmeta
  end

  def normalize_description(description)
    MetaTags::TextNormalizer.normalize_description(description)
  end

  def fix_time_zone(datetime)
    datetime.in_time_zone('UTC')
  end
end
