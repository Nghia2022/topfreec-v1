# frozen_string_literal: true

class Mypage::Fc::Directions::ApprovesPolicy < ApplicationPolicy
  def show?
    approve?
  end

  def create?
    approve?
  end

  private

  def approve?
    record.may_approve_by_fc?(fc_user: user)
  end
end
