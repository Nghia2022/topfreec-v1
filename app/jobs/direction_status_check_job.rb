# frozen_string_literal: true

class DirectionStatusCheckJob < ApplicationJob
  queue_as :default

  # disable :reek:TooManyStatements
  def perform
    ActiveRecord::Base.transaction do
      events = DirectionEvent.all.lock

      events.each do |event|
        next if finalize_by_mws(event)
        next if request_reconfirmation_to_client(event)
        next if request_confirmation_to_client(event)
      end

      DirectionEvent.delete(events.ids)
    end
  end

  private

  def finalize_by_mws(event)
    event.direction.finalize_by_mws! if event.perform_finalize?
  end

  # :nocov:
  def request_reconfirmation_to_fc(event)
    event.direction.request_reconfirmation_to_fc! if event.perform_request_reconfirmation_to_fc?
  end
  # :nocov:

  def request_reconfirmation_to_client(event)
    event.direction.request_reconfirmation_to_client! if event.perform_request_reconfirmation_to_client?
  end

  def request_confirmation_to_client(event)
    event.direction.request_confirmation_to_client! if event.perform_request_confirmation_to_client?
  end
end
