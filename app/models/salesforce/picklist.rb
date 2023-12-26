# frozen_string_literal: true

# Usage
# 1. Create a class that inherits from Salesforce::Picklist
# 2. Describe mapping.
#
# ex.
# class Project::Work_Prefecture < Salesforce::Picklist
#   mapping sobject: 'Opportunity', field_name: 'Work_Prefecture__c'
# end
#
# Note:
# - `id` is not usable for association.
#   It is generated depending on the order of the data, the id may change.
class Salesforce::Picklist < Salesforce::PicklistValue
  class << self
    def mapping(sobject:, field_name:)
      default_scope { where(sobject:, field: field_name).order(:position) }
    end
  end
end

# == Schema Information
#
# Table name: salesforce_picklist_values
#
#  id            :bigint           not null, primary key
#  active        :boolean
#  default_value :boolean
#  field         :string
#  label         :string
#  position      :integer
#  slug          :string
#  sobject       :string
#  valid_for     :string
#  value         :string
#  updated_at    :datetime
#
# Indexes
#
#  index_salesforce_picklist_values_on_position                     (position)
#  index_salesforce_picklist_values_on_sobject_and_field            (sobject,field)
#  index_salesforce_picklist_values_on_sobject_and_field_and_label  (sobject,field,label) UNIQUE
#  index_salesforce_picklist_values_on_sobject_and_field_and_slug   (sobject,field,slug) UNIQUE
#
