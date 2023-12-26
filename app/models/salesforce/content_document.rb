# frozen_string_literal: true

# :reek:MissingSafeMethod
# :nocov:
module Salesforce
  class ContentDocument < Base
    class << self
      def find_by(linked_id:, prefix:)
        links = restforce.query("select ContentDocumentId from ContentDocumentLink where LinkedEntityId = '#{linked_id}'")
        return if links.count.zero?

        documents = restforce.query(
          sanitize_sql_array(
            [
              'select Title, LastModifiedDate from ContentDocument where Id in (?) and Title LIKE ? order by LastModifiedDate desc LIMIT 1',
              links.map(&:ContentDocumentId),
              "#{prefix}%"
            ]
          )
        )
        documents.first
      end

      def create!(linked_id:, title:, file:)
        version_id = restforce.create!('ContentVersion', Title: title, PathOnClient: title, VersionData: version_data(file), IsMajorVersion: true)
        document_id = restforce.query("SELECT ContentDocumentId FROM ContentVersion WHERE Id = '#{version_id}' LIMIT 1").first.ContentDocumentId
        restforce.create!('ContentDocumentLink', ContentDocumentId: document_id, LinkedEntityId: linked_id, ShareType: 'I', Visibility: 'AllUsers')
      end

      private

      def version_data(file)
        Base64.encode64(file.read)
      end

      delegate :sanitize_sql_array, to: ActiveRecord::Base
    end
  end
end
# :nocov:
