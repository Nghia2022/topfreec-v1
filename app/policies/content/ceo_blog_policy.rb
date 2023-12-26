# frozen_string_literal: true

class Content::CeoBlogPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user&.wp_user?
        # :nocov:
        scope.with_draft
        # :nocov:
      else
        scope.published
      end
    end
  end
end
