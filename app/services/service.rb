# frozen_string_literal: true

module Service
  extend ActiveSupport::Concern

  class_methods do
    def call(*, **)
      new(*, **).send(:call)
    end

    def with(*argv, **kwargv)
      WithCaller.new(self, argv, kwargv)
    end
  end

  class WithCaller
    def initialize(klass, argv, kwargv)
      self.klass = klass
      self.argv = argv
      self.kwargv = kwargv
    end

    def call
      klass.new(*argv, **kwargv).send(:call)
    end

    private

    attr_accessor :klass, :argv, :kwargv
  end
end
