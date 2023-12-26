# frozen_string_literal: true

class StartEndDateValidator < ActiveModel::Validator
  def validate(record)
    start_as_date = record.send(options[:start_as_date])
    end_as_date = record.send(options[:end_as_date])

    return unless start_as_date.present? && end_as_date.present? && start_as_date > end_as_date

    record.errors.add(options[:end], :start_end_date, start: record.class.human_attribute_name(options[:start]))
  end
end
