# frozen_string_literal: true

class Mypage::Client::PasswordPolicy < ApplicationPolicy
  def edit?
    user.client?
  end

  def update?
    edit?
  end

  def permitted_attributes_for_update
    %i[
      current_password
      password
      password_confirmation
    ]
  end
end
