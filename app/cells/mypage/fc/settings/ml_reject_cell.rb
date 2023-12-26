# frozen_string_literal: true

class Mypage::Fc::Settings::MlRejectCell < ApplicationCell
  property :ml_reject?

  def show
    render
  end

  def enable_button
    render
  end

  def disable_button
    render
  end

  def toggle_button
    if ml_reject?
      enable_button
    else
      disable_button
    end
  end
end
