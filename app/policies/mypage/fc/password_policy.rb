# frozen_string_literal: true

class Mypage::Fc::PasswordPolicy < ApplicationPolicy
  def new?
    user.fc?
  end

  def create?
    new?
  end

  def edit?
    user.fc? || user.fc_company?
  end

  def update?
    edit?
  end

  def permitted_attributes_for_create
    %i[
      password
      password_confirmation
    ]
  end

  def permitted_attributes_for_update
    %i[
      current_password
      password
      password_confirmation
    ]
  end
end
