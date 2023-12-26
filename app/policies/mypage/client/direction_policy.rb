# frozen_string_literal: true

class Mypage::Client::DirectionPolicy < ApplicationPolicy
  def index?
    client?
  end

  class Scope < Scope
    def resolve
      scope
        .where(project: Project.of_cl_contact(user.contact))
        .where.not(status__c: :in_prepare)
    end
  end

  private

  def client?
    user.client?
  end
end
