# frozen_string_literal: true

class MatchingStatusCheckJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: false

  def initialize(*)
    self.failed = []
    super
  end

  def perform
    ActiveRecord::Base.transaction do
      notify_to_fc_users
      MatchingEvent.delete(events.ids - failed)
    end
  end

  private

  attr_accessor :failed

  def notify_to_fc_users
    events.each do |event|
      event.notify_to_fc_user
    rescue StandardError => e
      failed << event.id
    end
  end

  def events
    @events ||= MatchingEvent.joins(matching: :project).all.lock
  end
end
