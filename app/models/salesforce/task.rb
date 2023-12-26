# frozen_string_literal: true

module Salesforce
  class Task < Restforce::SObject
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::AttributeAssignment
    include SalesforceHelpers

    attribute :Subject, :string
    attribute :Status, :string
    attribute :EigyoType__c, :string
    attribute :ActivityDate, :date
    attribute :Description, :string
    attribute :OwnerId, :string
    attribute :Priority, :string
    attribute :WhatId, :string
    attribute :CompleteDate__c, :date

    alias_attribute :subject, :Subject
    alias_attribute :status, :Status
    alias_attribute :eigyo_type, :EigyoType__c
    alias_attribute :activity_date, :ActivityDate
    alias_attribute :description, :Description
    alias_attribute :owner_id, :OwnerId
    alias_attribute :priority, :Priority
    alias_attribute :whatid, :WhatId
    alias_attribute :complete_date, :CompleteDate__c

    def as_json
      attributes.compact.as_json
    end
  end
end
