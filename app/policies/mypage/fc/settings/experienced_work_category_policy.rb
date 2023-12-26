# frozen_string_literal: true

class Mypage::Fc::Settings::ExperiencedWorkCategoryPolicy < ApplicationPolicy
  def edit?
    update?
  end

  def update?
    user.fc? && record.owner?(user)
  end

  def permitted_attributes
    [{ experienced_works_sub: [] }]
  end
end
