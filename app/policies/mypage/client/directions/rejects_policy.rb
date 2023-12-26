# frozen_string_literal: true

class Mypage::Client::Directions::RejectsPolicy < ApplicationPolicy
  def show?
    reject?
  end

  def create?
    reject?
  end

  def permitted_attributes
    %i[new_direction_detail]
  end

  private

  def reject?
    record.may_reject_by_client?(client_user: user)
  end
end
