# frozen_string_literal: true

class Mypage::Client::HistoryPolicy < ApplicationPolicy
  def index?
    user.client?
  end
end
