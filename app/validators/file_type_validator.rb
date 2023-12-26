# frozen_string_literal: true

class FileTypeValidator < ActiveModel::EachValidator
  # :reek:FeatureEnvy
  def validate_each(record, attribute, value)
    return if options[:allowed_types].include?(Marcel::MimeType.for(value.tempfile, name: value.original_filename))

    record.errors.add(attribute, :disallowed)
  end
end
