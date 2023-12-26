# frozen_string_literal: true

class Mypage::Fc::Directions::RejectsPolicy < ApplicationPolicy
  def show?
    reject?
  end

  def create?
    reject?
  end

  def permitted_attributes
    %i[comment_from_fc]
  end

  private

  def reject?
    record.may_reject_by_fc?(fc_user: user)
  end
end
