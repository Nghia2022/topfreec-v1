# frozen_string_literal: true

class ChangedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _value)
    record.errors.add(attribute, :not_changed, **options.slice(:message)) unless record.send("will_save_change_to_#{attribute}?")
  end
end
