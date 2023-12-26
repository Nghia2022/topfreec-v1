# frozen_string_literal: true

# :reek:InstanceVariableAssumption, :reek:NilCheck
module Enumerize
  # = Enumerize::AASM
  # enumerizeをaasmに対応させるためのモンキーパッチ
  module AASM
    def define_methods!(mod)
      super(mod)

      mod._class_methods.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{name.to_s.pluralize}                                                     # def statuses
          @#{name}_enum_hash ||= #{name}.values.each_with_object({}) do |value, hash|  #   @status_enum_hash ||= status.values.each_with_object({}) do |value, hash|
            hash[value.to_s] = value.value                                             #     hash[value.to_s] = value.value
          end.with_indifferent_access                                                  #    end.with_indifferent_access
        end                                                                            # end
      RUBY
    end
  end

  # NOTE: 存在しない値が設定されているデータがnilに書き換わらないようにする
  module AllowInvalid
    def find_value(value)
      @value_hash[value.to_s] || Value.new(self, value) unless value.nil?
    end
  end
end

Enumerize::Attribute.prepend Enumerize::AASM
