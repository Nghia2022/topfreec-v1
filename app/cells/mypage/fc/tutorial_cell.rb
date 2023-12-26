# frozen_string_literal: true

class Mypage::Fc::TutorialCell < ApplicationCell
  def show(cookies)
    prepare_cookies(cookies)
    render if enable_tutorial?
  end

  private

  attr_accessor :enable_tutorial

  def prepare_cookies(cookies)
    self.enable_tutorial = cookies.permanent[:enable_tutorial].present?
    return unless enable_tutorial

    cookies.delete(:enable_tutorial)
  end

  def enable_tutorial?
    enable_tutorial
  end
end
