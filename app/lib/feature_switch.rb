# frozen_string_literal: true

class FeatureSwitch
  include Singleton

  def enabled?(*features)
    enabled_any?(features).tap do |enabled|
      yield if enabled && block_given?
    end
  end

  class << self
    extend Forwardable

    def_delegators :instance, :enabled?
    def_delegators Flipper, :enable, :disable, :remove

    # :nocov:
    def add(feature, **_)
      Flipper.add(feature)
    end
    # :nocov:
  end

  private

  def enabled_any?(*features)
    features.flatten.any? { |feature| Flipper.enabled?(feature) }
  end
end
