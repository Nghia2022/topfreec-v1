# frozen_string_literal: true

module CompensationFormattable
  include FormatMixins
  include ActionView::Helpers::TagHelper

  module Current
    def compensations_for_abstract
      @compensations_for_abstract ||= compensations.join('-')
    end

    def compensations_for_details
      @compensations_for_details ||= compensations.join(' 〜 ')
    end

    private

    def compensations
      return [] unless min?

      ranged? ? [min_text, max_text] : [max_text]
    end

    def min?
      compensation_min.present?
    end

    def max?
      compensation_max.present?
    end

    def ranged?
      compensation_min != compensation_max
    end

    def min_text
      "#{compensation_min.to_i}#{max? ? '' : currency}"
    end

    def max_text
      compensation_max.present? ? "#{compensation_max.to_i}#{currency}" : '応相談'
    end

    def currency
      tag.span '万円', class: 'currency'
    end
  end

  # disable :reek:UncommunicativeModuleName
  module V2022
    # rubocop:disable Rails/OutputSafety
    def compensations_for_abstract
      @compensations_for_abstract ||= compensations('-').html_safe
    end

    def compensations_for_details
      @compensations_for_details ||= compensations('〜').html_safe
    end

    # rubocop:enable Rails/OutputSafety

    # disable :reek:DuplicateMethodCall
    def compensations(delimiter)
      case [compensation_min, compensation_max]
      in [nil, nil]
        ''
      in [nil, text]
        "#{text.to_i}万円"
      in [text, nil]
        "#{text.to_i}万円#{delimiter}応相談"
      in [min, max]
        if min == max
          "#{max.to_i}万円"
        else
          "#{min.to_i}#{delimiter}#{max.to_i}万円"
        end
      end
    end
  end
end
