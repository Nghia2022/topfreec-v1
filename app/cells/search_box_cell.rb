# frozen_string_literal: true

class SearchBoxCell < ApplicationCell
  include ActionView::Helpers::FormOptionsHelper

  def show(layout: 'layout')
    render layout:
  end
end
