# frozen_string_literal: true

# :nocov:
module Salesforce
  class Lead
    class << self
      def find_or_create_by(params)
        fields = %i[Id Email LeadId__c]

        result = restforce.query("select #{fields.join(', ')} from Lead where Email = '#{params[:Email]}'")
        if result.count.zero?
          sfid = RestforceFactory.new_client.create!('Lead', params)
          restforce.select('Lead', sfid, fields)
        else
          result.first
        end
      end

      private

      def restforce
        @restforce ||= RestforceFactory.new_client
      end
    end
  end
end
# :nocov:
