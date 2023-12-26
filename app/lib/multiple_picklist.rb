# frozen_string_literal: true

module MultiplePicklist
  class << self
    def dump(value)
      value&.join(';').presence
    end

    def load(source)
      source&.split(';')
    end
  end
end
