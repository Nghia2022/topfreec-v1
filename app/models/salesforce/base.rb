# frozen_string_literal: true

module Salesforce
  class Base < Restforce::SObject
    include SalesforceHelpers

    class << self
      # :nocov:
      def _find_multi(object, ids, fields)
        sql = sanitize_sql_array [format('SELECT %<fields>s FROM %<object>s WHERE Id IN (?)', object:, fields: fields.join(', ')), ids]
        restforce.query(sql).to_a.map do |record|
          new(record)
        end
      end
      # :nocov:

      delegate :sanitize_sql_array, to: ActiveRecord::Base
    end
  end
end
