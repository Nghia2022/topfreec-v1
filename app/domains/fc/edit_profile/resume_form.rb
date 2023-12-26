# frozen_string_literal: true

module Fc::EditProfile
  class ResumeForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment
    include ActiveModel::Dirty
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks
    include CacheSupport

    TITLE_PREFIX = 'fcweb-resume-'
    ALLOWED_TYPES = %w[
      application/vnd.openxmlformats-officedocument.wordprocessingml.document
      application/msword
      application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
      application/vnd.ms-powerpoint
      application/vnd.openxmlformats-officedocument.presentationml.presentation
      application/vnd.ms-excel
    ].freeze
    ACCEPT_EXTENSIONS = %w[
      docx
      doc
      xlsx
      xls
      pptx
      ppt
    ].freeze
    SIZE_LIMIT_MB = 2

    attribute :document, :binary
    validates :document, presence: true
    validates :document, file_type: { allowed_types: ALLOWED_TYPES }, file_size: { limit_mb: SIZE_LIMIT_MB }, allow_blank: true

    class << self
      def permitted_attributes
        %i[document]
      end

      def last_uploaded_at(linked_sfid)
        cached_record_of linked_sfid, expires_in: 1.hour do
          last_modified_date = Salesforce::ContentDocument.find_by(linked_id: linked_sfid, prefix: TITLE_PREFIX)&.LastModifiedDate
          Time.zone.parse(last_modified_date) if last_modified_date.present?
        end
      end

      def accepts
        ACCEPT_EXTENSIONS.map { |ext| ".#{ext}" }.join(',')
      end
    end

    def save(linked_sfid)
      return false unless valid?

      self.persisted = upload_document(linked_sfid)
      Rails.cache.delete self.class.cache_key_record(linked_sfid) if persisted?

      persisted
    end

    def persisted?
      persisted
    end

    private

    attr_writer :persisted

    def persisted
      @persisted ||= false
    end

    def upload_document(linked_sfid)
      Salesforce::ContentDocument.create!(linked_id: linked_sfid, title: document_title, file: document.tempfile)
    rescue Restforce::ResponseError => e
      # :nocov:
      errors.add(:base, 'アップロードに失敗しました')
      false
      # :nocov:
    end

    def document_title
      "#{TITLE_PREFIX}#{document.original_filename}"
    end
  end
end
