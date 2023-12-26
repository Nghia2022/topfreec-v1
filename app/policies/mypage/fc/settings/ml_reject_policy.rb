# frozen_string_literal: true

class Mypage::Fc::Settings::MlRejectPolicy < ApplicationPolicy
  def index?
    update?
  end

  def edit?
    update?
  end

  def destroy?
    update?
  end

  def update?
    user.fc? && record.owner?(user)
  end
end
