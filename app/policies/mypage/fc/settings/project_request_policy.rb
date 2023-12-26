# frozen_string_literal: true

class Mypage::Fc::Settings::ProjectRequestPolicy < ApplicationPolicy
  def edit?
    update?
  end

  def update?
    user.fc? && record.owner?(user)
  end

  def permitted_attributes
    %i[
      start_timing
      reward_min
      reward_desired
      requests
      occupancy_rate
    ]
  end
end
