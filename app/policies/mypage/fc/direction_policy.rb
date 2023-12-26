# frozen_string_literal: true

class Mypage::Fc::DirectionPolicy < ApplicationPolicy
  def index?
    active_fc?
  end

  class Scope < Scope
    def resolve
      user_scope.merge(status_scope)
    end

    def user_scope
      directions = scope.where(project: Project.of_fc_contact(user.contact))
      ActiveType.cast(directions, Fc::ManageDirection::Direction)
    end

    def status_scope
      [
        scope.where(status__c: %i[waiting_for_fc completed]),
        scope.where(status__c: :rejected).where.not(commentfromfc__c: [nil, ''])
      ].inject(:or)
    end
  end

  private

  def active_fc?
    [
      user.fc? && user.activated?,
      user.fc_company?
    ].any?
  end
end
