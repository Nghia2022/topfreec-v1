# frozen_string_literal: true

class Mypage::Fc::Profiles::QualificationCell < ApplicationCell
  include EditLinkable
  delegate :license?, to: :model

  def show
    render
  end

  def licenses
    text_format model.license
  end
end
