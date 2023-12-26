# frozen_string_literal: true

# :nocov:
module Readonlyable
  extend ActiveSupport::Concern

  included do
    class_attribute :readonly_enabled

    self.readonly_enabled = !Rails.env.test?

    def readonly?
      readonly_enabled
    end

    def before_destroy
      raise ActiveRecord::ReadOnlyRecord if readonly_enabled
    end
  end

  module ClassMethods
    def delete(_id)
      raise ActiveRecord::ReadOnlyRecord if readonly_enabled

      super
    end

    def delete_all(_conditions)
      raise ActiveRecord::ReadOnlyRecord if readonly_enabled

      super
    end

    def update_all(_conditinos)
      raise ActiveRecord::ReadOnlyRecord if readonly_enabled

      super
    end
  end
end
# :nocov:
