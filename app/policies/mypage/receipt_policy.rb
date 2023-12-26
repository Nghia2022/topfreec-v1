# frozen_string_literal: true

class Mypage::ReceiptPolicy < ApplicationPolicy
  def update?
    record.receiver == user
  end

  class Scope < Scope
    def resolve
      scope.merge(user.receipts)
    end
  end
end
