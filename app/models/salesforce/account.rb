# frozen_string_literal: true

module Salesforce
  class Account < Restforce::SObject
    include SalesforceHelpers

    NullObject = Naught.build

    class << self
      def null
        NullObject.new
      end

      def find(id, fields = [])
        new(restforce.select('Account', id, fields))
      end
    end
  end
end
