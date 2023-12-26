# frozen_string_literal: true

module Salesforce
  class User < Base
    NullObject = Naught.build

    def full_name
      [
        self[:LastName],
        self[:FirstName]
      ].join ' '
    end

    def email
      self[:Email]
    end

    class << self
      # :nocov:
      def find(id, fields = [])
        new(restforce.select('User', id, fields))
      end
      # :nocov:

      # :nocov:
      def find_multi(ids, fields)
        _find_multi('User', ids, fields)
      end
      # :nocov:

      # :nocov:
      def null
        NullObject.new
      end
      # :nocov:
    end
  end
end
