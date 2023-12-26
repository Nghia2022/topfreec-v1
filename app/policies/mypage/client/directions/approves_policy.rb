# frozen_string_literal: true

class Mypage::Client::Directions::ApprovesPolicy < ApplicationPolicy
  def show?
    approve?
  end

  def create?
    approve?
  end

  private

  def approve?
    record.may_approve_by_client?(client_user: user)
  end
end
