# frozen_string_literal: true

module SalesforceHelpers
  extend ActiveSupport::Concern

  included do
    class_attribute :sobject_name

    def to_sobject(fields = [])
      restforce.select(self.class.sobject_name, sfid, fields)
    end

    def restforce
      @restforce ||= RestforceFactory.new_client
    end

    def cache_key_with_version
      return super unless has_attribute?(:systemmodstamp)

      timestamp = systemmodstamp
      version = timestamp.utc.to_fs(cache_timestamp_format) if timestamp
      [cache_key, *version].join('-')
    end
  end

  class_methods do
    def restforce
      @restforce ||= RestforceFactory.new_client
    end

    def acts_as_recordtypable(options = {})
      self.inheritance_column = 'recordtypeid'
      include SalesforceRecordTypable
      self.recordtypable_configuration = options
    end

    # :nocov:
    def describe
      @describe ||= RestforceFactory.new_client.describe sobject_name
    end

    def cache_describe
      describe.tap do |desc|
        File.write describe_cache_path, JSON.pretty_generate(desc.as_json)
      end
    end

    def cached_describe
      if File.exist? describe_cache_path
        json = JSON.parse(File.read(describe_cache_path))
        Restforce::Mash.new(json)
      else
        cache_describe
      end
    end

    def cached_describe_field(name)
      fields = cached_describe.fields

      fields.find do |field|
        field.name == name
      end
    end
    # ex.) Opportunity.f("wowrk_prefectures__c").picklistValues
    alias_method :f, :cached_describe_field if Rails.env.development?
    def describe_cache_path
      Rails.root.join 'db', 'sobject_describe_cache', "#{sobject_name}.json"
    end

    def record_type_ids
      describe.recordTypeInfos.to_h { |rt| [rt.name, rt.recordTypeId] }
    end
    # :nocov:
  end
end
