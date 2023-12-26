# frozen_string_literal: true

class Mypage::Fc::Profiles::QualificationPolicy < ApplicationPolicy
  def edit?
    update?
  end

  def update?
    user.fc? && record.owner?(user)
  end

  def permitted_attributes
    %i[license]
  end
end
