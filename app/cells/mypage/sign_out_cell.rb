# frozen_string_literal: true

class Mypage::SignOutCell < ApplicationCell
  def show
    render
  end

  private

  def sign_out_path
    options[:sign_out_path]
  end
end
