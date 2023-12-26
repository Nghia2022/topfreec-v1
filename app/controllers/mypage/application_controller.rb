# frozen_string_literal: true

class Mypage::ApplicationController < ApplicationController
  layout 'mypage/application'

  before_action :set_body_class

  private

  def set_body_class
    @body_class = :mypage
  end
end
