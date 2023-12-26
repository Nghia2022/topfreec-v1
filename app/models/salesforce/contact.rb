# frozen_string_literal: true

module Salesforce
  class Contact < Base
    NullObject = Naught.build

    class << self
      # :nocov:
      def find_multi(ids, fields)
        _find_multi('Contact', ids, fields)
      end
      # :nocov:

      def null
        NullObject.new
      end
    end
  end
end
