# frozen_string_literal: true

require 'uri'

class EmailValidator < ActiveModel::EachValidator
  # disable :reek:UtilityFunction
  def validate_each(record, _attribute, value)
    return if value.blank?
    return if value.match?(URI::MailTo::EMAIL_REGEXP)

    record.errors.add(:email, :invalid)
  end
end
