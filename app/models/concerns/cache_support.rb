# frozen_string_literal: true

module CacheSupport
  extend ActiveSupport::Concern

  module ClassMethods
    def cached_record_of(id, options = {}, &)
      Rails.cache.fetch(cache_key_record(id), options, &)
    end

    def cache_key_record(id)
      "/models/cache_support/cache_key_record/#{model_name.to_s.underscore}/#{id}"
    end
  end

  def cache_sobject(key, options = {})
    raise ArgumentError, 'need a block' unless block_given?

    cached_data = Rails.cache.fetch(key, options) do
      JSON.generate(yield)
    end
    Restforce::SObject.new(JSON.parse(cached_data))
  end
end
