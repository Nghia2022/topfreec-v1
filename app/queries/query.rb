# frozen_string_literal: true

module Query
  extend ActiveSupport::Concern

  class_methods do
    def call(**)
      new(**).call
    end
  end
end
