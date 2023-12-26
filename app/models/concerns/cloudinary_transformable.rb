# frozen_string_literal: true

module CloudinaryTransformable
  extend ActiveSupport::Concern

  class_methods do
    def cloudinary_transform(name, options = {})
      define_method(:"#{name}_transforms") do
        key = "@#{name}_transforms".to_sym
        return instance_variable_get(key) if instance_variable_defined?(key)

        instance_variable_set(key, CloudinaryTransforms.new(public_send(name), options))
      end
    end
  end
end
