# frozen_string_literal: true

module SalesforceTimestamp
  extend ActiveSupport::Concern

  included do
    alias_attribute :created_at, :createddate
    alias_attribute :updated_at, :systemmodstamp
  end

  class_methods do
    def timestamp_attributes_for_create
      super + %w[createddate]
    end

    def timestamp_attributes_for_update
      super + %w[systemmodstamp]
    end
  end
end
