# frozen_string_literal: true

module SalesforceRecordTypable
  extend ActiveSupport::Concern

  included do
    class_attribute :recordtypable_configuration
  end

  class_methods do
    def find_sti_class(type)
      type_name = recordtypeid.values.find { |value| value == type }
      if recordtypable_configuration[:module]
        type_name = [
          recordtypable_configuration[:module].to_s.camelize,
          type_name.to_s.camelize
        ].join('::')
      end
      type_name.to_s.camelize.constantize
    end

    def sti_name
      recordtypeid.values.find { |value| value == name.demodulize.underscore }&.value
    end
  end
end
