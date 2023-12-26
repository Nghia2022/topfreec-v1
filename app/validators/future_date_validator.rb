# frozen_string_literal: true

class FutureDateValidator < ActiveModel::EachValidator
  # disable :reek:UtilityFunction
  def validate_each(record, attribute, value)
    return if value.blank?

    record.errors.add(attribute, 'は現在より未来の日付を選択してください') if value.to_date < Time.zone.today
  end
end
