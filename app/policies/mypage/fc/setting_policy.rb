# frozen_string_literal: true

class Mypage::Fc::SettingPolicy < ApplicationPolicy
  def index?
    user.fc? || user.fc_company?
  end
end
