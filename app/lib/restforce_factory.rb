# frozen_string_literal: true

module RestforceFactory
  def self.new_client(options = {})
    credentials = Rails.application.credentials.fetch(:salesforce, {})
    options = options.merge(credentials).merge(api_version: '46.0')
    Restforce.new(options)
  end

  def self.new_tooling(options = {})
    credentials = Rails.application.credentials.fetch(:salesforce, {})
    options = options.merge(credentials).merge(api_version: '46.0')
    Restforce.tooling(options)
  end
end
