# frozen_string_literal: true

class Topic::ItemCell < ApplicationCell
  property :post_title
  property :post_content

  def row
    render
  end

  private

  def post_link
    parsed_post_content[:href]
  end

  def post_content_text
    parsed_post_content[:text]
  end

  def parsed_post_content
    @parsed_post_content ||= begin
      node = Nokogiri::HTML.parse(post_content)
      tag = node.search('a')[0]
      if tag
        {
          href: tag.attributes['href'],
          text: tag.text
        }
      else
        {
          text: post_content
        }
      end
    end
  end
end
