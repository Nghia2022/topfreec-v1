# frozen_string_literal: true

module I18n
  module Relaxed
    def ln(object, locale: nil, format: nil, **)
      object.presence && l(object, locale:, format:, **)
    end
  end
end

I18n.extend I18n::Relaxed
