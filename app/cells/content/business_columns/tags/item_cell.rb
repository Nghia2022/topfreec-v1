# frozen_string_literal: true

class Content::BusinessColumns::Tags::ItemCell < ApplicationCell
  property :name
  property :slug

  def show
    render
  end

  private

  def url
    corp_business_columns_path(bccat: slug)
  end

  def selected?
    options[:selected] == model.slug
  end

  def html_class
    class_names('btn btn-type05 w-auto sp-mt10', 'bg-red c-white': selected?, 'bg-border-light-gray c-gray': !selected?)
  end
end
