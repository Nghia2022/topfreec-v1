# frozen_string_literal: true

class ConversionCell < ApplicationCell
  def show
    return unless conversion_needed?
    return if ignored?

    render
  end

  private

  def session_id
    request.session_options[:id]
  end

  def conversion_needed?
    %w[
      /register/thanks
    ].include?(request.path)
  end

  def ignored?
    ::Rails.env.development?
  end
end
