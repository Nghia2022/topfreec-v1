# frozen_string_literal: true

class WordpressImageReplacer
  FROM = 'https://freeconsultant.jp/'
  TO = 'https://file.freeconsultant.jp/'

  class << self
    def replace(source)
      return if source.blank?

      if source.starts_with?(/https?:/)
        replace_urls(source)
      else
        replace_image_tags(source)
      end
    end

    private

    def replace_urls(url)
      url&.gsub(FROM, TO)
    end

    def replace_image_tags(html)
      doc = Nokogiri::HTML.fragment(html)
      doc.search('img').each do |img|
        img[:src] = replace_urls(img[:src])
        img[:srcset] = replace_urls(img[:srcset]) if img[:srcset].present?
      end
      doc.to_html
    end
  end
end
