# frozen_string_literal: true

class Content::BusinessColumns::TagsCell < ApplicationCell
  def show
    cell(Content::BusinessColumns::Tags::ItemCell, collection: column_tags, selected: model).call(:show)
  end

  private

  def column_tags
    [Wordpress::WpTerm.null] + options[:column_tags]
  end
end
