# frozen_string_literal: true

class Mypage::Fc::HistoryPolicy < ApplicationPolicy
  def index?
    user.fc?
  end
end
