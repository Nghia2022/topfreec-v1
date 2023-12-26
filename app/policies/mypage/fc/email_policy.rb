# frozen_string_literal: true

class Mypage::Fc::EmailPolicy < ApplicationPolicy
  def edit?
    update?
  end

  def update?
    user.fc? || user.fc_company?
  end

  def permitted_attributes
    %i[email email_confirmation]
  end
end
