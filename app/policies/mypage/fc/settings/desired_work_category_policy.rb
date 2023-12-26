# frozen_string_literal: true

class Mypage::Fc::Settings::DesiredWorkCategoryPolicy < ApplicationPolicy
  def edit?
    update?
  end

  def update?
    user.fc? && record.owner?(user)
  end

  def permitted_attributes
    [{ desired_works_sub: [] }]
  end
end
