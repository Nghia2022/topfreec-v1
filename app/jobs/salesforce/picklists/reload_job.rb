# frozen_string_literal: true

class Salesforce::Picklists::ReloadJob < ApplicationJob
  queue_as :default

  def perform(sobject_name: nil)
    Salesforce::Picklists::ReloadService.call(sobject_name:)
  end
end
