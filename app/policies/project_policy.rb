# frozen_string_literal: true

class ProjectPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    record.published?
  end

  class Scope < Scope
    def resolve
      scope.published
    end
  end
end
