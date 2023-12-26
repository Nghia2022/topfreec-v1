# frozen_string_literal: true

class Projects::NewArrivalCell < ApplicationCell
  def show
    render
  end

  private

  def items
    model
  end

  def _last_updated_at
    items.max_by(&:updated_at)&.updated_at
  end

  def last_updated_at
    I18n.ln(_last_updated_at, format: '%-m月%-d日（%a）')
  end

  class << self
    def total
      Project.published.new_arrival.count
    end
  end
end
