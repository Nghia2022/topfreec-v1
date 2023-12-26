# frozen_string_literal: true

class UnusedEmailValidator < ActiveModel::EachValidator
  # :reek:UtilityFunction
  def validate_each(record, attribute, value)
    record.errors.add(attribute, :taken) if Contact.where.not(sfid: record.contact_sfid).exists?(web_loginemail__c: value)
  end
end
