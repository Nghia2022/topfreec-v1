# frozen_string_literal: true

class Mypage::NotificationCell < ApplicationCell
  property :subject

  def show
    if model.empty?
      render view: :empty, layout: :layout
    else
      render view: :show, layout: :layout
    end
  end

  def item
    render
  end

  private

  def link
    model.notification.link || '#'
  end
end
