# frozen_string_literal: true

class Mypage::Client::ProfilePolicy < ApplicationPolicy
  def show?
    user.client?
  end

  def edit?
    update?
  end

  def update?
    user.client?
  end
end
