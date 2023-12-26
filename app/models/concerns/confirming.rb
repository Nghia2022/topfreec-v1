# frozen_string_literal: true

module Confirming
  extend ActiveSupport::Concern

  included do
    attr_accessor :confirming

    validates :confirming, acceptance: true
    after_validation :check_confirming

    def confirming
      @confirming ||= ''
    end

    def check_confirming
      errors.delete(:confirming)
      self.confirming = errors.empty? ? '1' : ''
    end

    def confirming?
      confirming == '1'
    end

    def reset_confirming
      self.confirming = ''
    end

    # :nocov:
    def finish_confirming
      self.confirming = '1'
    end
    # :nocov:
  end
end
