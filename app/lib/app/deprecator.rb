# frozen_string_literal: true

# :nocov:
module App
  class Deprecator
    # disable :reek:UtilityFunction
    def deprecation_warning(deprecated_method_name, message, _caller_backtrace = nil)
      message = "#{deprecated_method_name} is deprecated and will be removed from App | #{message}"
      Kernel.warn message
    end

    class << self
      def instance
        @instance ||= new
      end
    end
  end
end
# :nocov:
