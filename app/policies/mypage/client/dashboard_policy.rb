# frozen_string_literal: true

class Mypage::Client::DashboardPolicy < ApplicationPolicy
  def index?
    user.client?
  end
end
