# frozen_string_literal: true

class Content::ColumnPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user&.wp_user?
        scope.with_draft
      else
        scope.published
      end
    end
  end
end
