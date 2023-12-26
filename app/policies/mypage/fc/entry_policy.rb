# frozen_string_literal: true

class Mypage::Fc::EntryPolicy < ApplicationPolicy
  def index?
    active_fc?
  end

  def destroy?
    active_fc? && record.owner?(user) && (record.can_decline_immediately? || record.can_decline_with_reason?)
  end

  # :nocov:
  def decline?
    destroy?
  end
  # :nocov:

  class Scope < Scope
    def resolve
      scope.for_entry_history
    end
  end

  def permitted_attributes
    %i[ng_reason]
  end

  private

  def active_fc?
    user.fc? && user.activated?
  end
end
