# frozen_string_literal: true

class Content::MenuCell < ApplicationCell
  def show
    render
  end

  def corp
    render
  end

  private

  def title
    options[:title]
  end

  def subtitle
    options[:subtitle]
  end

  def description
    options[:description]
  end

  def column?
    model == :column
  end

  def workstyle?
    model == :workstyle
  end

  def ceo_blog?
    model == :ceo_blog
  end
end
