# frozen_string_literal: true

class Mypage::Fc::ExperiencePolicy < ApplicationPolicy
  def index?
    active_fc?
  end

  private

  def active_fc?
    user.fc? && user.activated?
  end
end
