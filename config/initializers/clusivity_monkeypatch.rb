# frozen_string_literal: true

module ActiveModel::Validations::Clusivity
  module ArrayMonkeyPatch
    # refs: https://github.com/rails/rails/blob/ca3e163b7cf8549eb39018d88da5cd9bcd9dcadb/activemodel/lib/active_model/validations/clusivity.rb#L18-L32
    # disable :reek:DuplicateMethodCall, :reek:ManualDispatch, :reek:TooManyStatements, :reek:UncommunicativeVariableName
    def include?(record, value)
      members = if delimiter.respond_to?(:call)
                  delimiter.call(record)
                elsif delimiter.respond_to?(:to_sym)
                  record.send(delimiter)
                else
                  delimiter
                end

      if value.is_a?(Array)
        value.all? { |v| members.public_send(inclusion_method(members), v) }
      else
        members.public_send(inclusion_method(members), value)
      end
    end
  end
end

ActiveSupport::Reloader.to_prepare do
  ActiveModel::Validations::InclusionValidator.prepend ActiveModel::Validations::Clusivity::ArrayMonkeyPatch
end
