# frozen_string_literal: true

class Mypage::Fc::EntryCell < ApplicationCell
  def show
    render
  end

  def message
    render
  end

  private

  def current_count
    current_user.account.matchings.for_entry_count.count
  end

  def entry_limit
    options.fetch(:entry_limit, 7)
  end

  def remaining_count
    entry_limit - current_count
  end

  def reached_limit?
    remaining_count.zero?
  end

  def no_entry?
    current_count.zero?
  end
end
