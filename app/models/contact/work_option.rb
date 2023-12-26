# frozen_string_literal: true

class Contact::WorkOption < Salesforce::Picklist
  mapping sobject: 'Contact', field_name: 'Work_Options__c'
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
