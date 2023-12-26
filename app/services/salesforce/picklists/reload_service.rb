# frozen_string_literal: true

module Salesforce::Picklists
  class ReloadService
    include Service

    def initialize(sobject_name: nil)
      @sobject_name = [sobject_name].flatten if sobject_name.present?
      @mappings = load_mappings # Initialize mappings here
    end

    def call
      ApplicationRecord.transaction do
        reload_all_picklist
      end
    end

    private

    attr_reader :sobject_name, :mappings

    def load_mappings
      mappings_file_path = Rails.root.join('db/herokuconnect.json')

      raise "Mappings file not found at #{mappings_file_path}" unless File.exist?(mappings_file_path)

      JSON.parse(File.read(mappings_file_path))
    rescue JSON::ParserError => e
      raise "Error parsing mappings JSON: #{e.message}"
    end

    def reload_all_picklist
      values = build_all_picklist_values

      ids = Salesforce::PicklistValue
            .upsert_all(values, unique_by: %i[sobject field label], returning: %i[id]) # rubocop:disable Rails/SkipsModelValidations
      reload_scope.where.not(id: ids.pluck('id')).delete_all
    end

    def reload_scope
      if sobject_name
        Salesforce::PicklistValue.where(sobject: sobject_name)
      else
        Salesforce::PicklistValue.all
      end
    end

    # :reek:NestedIterators
    def build_all_picklist_values
      all_sobject_with_picklist_fields.map do |sobject, fields|
        fields.map do |field|
          build_field_attributes(sobject, field)
        end
      end.flatten
    end

    # :reek:FeatureEnvy
    def build_field_attributes(sobject, field)
      field.picklistValues.map.with_index(1) do |value, index|
        value.transform_keys(&:underscore)
             .merge(sobject:, field: field.name)
             .merge(position: index, slug: generate_slug(value.label), updated_at: Time.current)
      end
    end

    def generate_slug(label)
      Salesforce::PicklistValue.generate_slug(label)
    end

    def all_sobject_with_picklist_fields
      sobjects.index_with do |sobject|
        picklist_fields(sobject)
      end
    end

    def sobjects
      sobject_name || mappings['mappings'].pluck('object_name')
    end

    def mapped_fields(sobject_name)
      mappings['mappings'].find { |mapping| mapping['object_name'] == sobject_name }&.dig('config', 'fields')&.keys
    end

    def picklist_fields(sobject_name)
      fields = mapped_fields(sobject_name)
      restforce.describe(sobject_name).fields
               .select { |field| %w[picklist multipicklist].include?(field.type) }
               .select { |field| fields.include?(field.name) }
    end

    def restforce
      @restforce ||= RestforceFactory.new_client
    end
  end
end
