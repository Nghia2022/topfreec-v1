# frozen_string_literal: true

class Mypage::ReceiptsController < ApplicationController
  before_action :authenticate_user!

  def update
    receipt.mark_as_read
    head :no_content
  end

  private

  def receipt
    @receipt ||= policy_scope(Receipt, policy_scope_class: Mypage::ReceiptPolicy::Scope).find(params[:id]).tap do |receipt|
      authorize receipt, policy_class: Mypage::ReceiptPolicy
    end
  end
end
