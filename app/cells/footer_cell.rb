# frozen_string_literal: true

class FooterCell < ApplicationCell
  include ActionView::Helpers::FormOptionsHelper
  include SwitchUserHelper

  def show
    render
  end
end
