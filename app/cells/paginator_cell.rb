# frozen_string_literal: true

class PaginatorCell < ApplicationCell
  def show
    render
  end

  alias scope model
end
