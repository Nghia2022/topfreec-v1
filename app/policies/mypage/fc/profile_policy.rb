# frozen_string_literal: true

class Mypage::Fc::ProfilePolicy < ApplicationPolicy
  def show?
    user.fc?
  end

  def edit?
    update?
  end

  def update?
    user.fc?
  end
end
