# frozen_string_literal: true

class TrackingCell < ApplicationCell
  def head
    return if ignored?

    render
  end

  def body_opening
    render
  end

  private

  def ignored?
    ::Rails.env.development?
  end
end
