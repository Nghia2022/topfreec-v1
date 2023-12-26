# frozen_string_literal: true

class FileSizeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.size.to_i <= limit.megabytes

    record.errors.add(attribute, :size_limit_exceeded, limit:)
  end

  private

  def limit
    options[:limit_mb]
  end
end
