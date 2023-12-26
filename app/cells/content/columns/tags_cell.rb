# frozen_string_literal: true

class Content::Columns::TagsCell < ApplicationCell
  def show
    cell(Content::Columns::Tags::ItemCell, collection: column_tags, selected: model).call(:show)
  end

  private

  def column_tags
    [Wordpress::WpTerm.null] + options[:column_tags]
  end
end
