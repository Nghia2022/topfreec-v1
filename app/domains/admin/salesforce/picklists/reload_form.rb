# frozen_string_literal: true

class Admin::Salesforce::Picklists::ReloadForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :sobject_name

  class << self
    def sobject_names
      @sobject_names ||= Salesforce::PicklistValue.distinct(:sobject).pluck(:sobject).sort
    end
  end

  validates :sobject_name, inclusion: { in: ->(_) { sobject_names }, allow_blank: true }
end
