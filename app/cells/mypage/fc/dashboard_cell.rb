# frozen_string_literal: true

class Mypage::Fc::DashboardCell < ApplicationCell
  def show
    render
  end

  private

  def last_profile_updated_at
    I18n.l(model.available_date, format: :date, default: '-')
  end

  def last_entry_at
    I18n.l(model.last_entry_at, format: :date, default: '-')
  end

  def pending_directions
    options.fetch(:pending_directions_count, 0).positive? ? 'あり' : 'なし'
  end

  def entries_count
    model.matchings.for_entry_count.count
  end
end
