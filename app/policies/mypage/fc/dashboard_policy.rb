# frozen_string_literal: true

class Mypage::Fc::DashboardPolicy < ApplicationPolicy
  def index?
    user.fc? || user.fc_company?
  end
end
