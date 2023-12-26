# frozen_string_literal: true

class DirectionAutoApproveJob < ApplicationJob
  queue_as :default

  def perform
    Fc::ManageDirection::AutoApproveService.call
    Client::ManageDirection::AutoApproveService.call
  end
end
