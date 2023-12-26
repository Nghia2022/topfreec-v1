# frozen_string_literal: true

class Salesforce::PicklistValue < ApplicationRecord
  class << self
    def generate_slug(label)
      Base64.urlsafe_encode64(OpenSSL::PKCS5.pbkdf2_hmac(label, '', 1, 12, 'sha256'))
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
