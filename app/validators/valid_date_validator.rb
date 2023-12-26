# frozen_string_literal: true

# :nocov:
class ValidDateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    assign_values(record, attribute)
    verify_before_cast_value
  rescue ArgumentError
    set_error
    reset_attribute
  end

  private

  attr_accessor :record, :attribute

  def assign_values(record, attribute)
    self.record = record
    self.attribute = attribute
  end

  def verify_before_cast_value
    before_cast_value = fetch_before_cast_value
    if before_cast_value.respond_to?(:to_date)
      before_cast_value.to_date
    else
      Date.new(*before_cast_value.values)
    end
  end

  def fetch_before_cast_value
    record.public_send("#{attribute}_before_type_cast")
  end

  def set_error
    record.errors.add(attribute, 'は存在する日付を選択してください')
  end

  def reset_attribute
    record.write_attribute(attribute, nil)
  end
end
# :nocov:
