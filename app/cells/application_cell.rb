# frozen_string_literal: true

class ApplicationCell < Cell::ViewModel
  include Cell::Slim
  include Cell::Erb
  include ApplicationHelper
  include Kaminari::Cells
  include ActionView::Helpers::TranslationHelper
  include Devise::Controllers::Helpers

  attr_reader :action_name

  def call(state = :show, *args)
    @action_name = state
    @virtual_path = self.class.name.sub(/Cell$/, '').underscore
    super
  end

  def find_template(options)
    prefixes = options[:prefixes]

    template, views = find_template_from_lookup_context(options)

    template or raise ::Cell::TemplateMissingError.new(prefixes, views)
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def find_template_from_lookup_context(options)
    prefixes = options[:prefixes]
    views = []
    found = nil

    controller.lookup_context.handlers.each do |handler|
      next unless respond_to?(:"template_options_for_#{handler}")

      template_options = __send__(:"template_options_for_#{handler}", options)

      suffix = template_options.delete(:suffix)
      variant = template_options.delete(:variant)

      ['', '.html', ".html+#{variant}"].reverse.each do |ext|
        views << "#{options[:view]}#{ext}.#{suffix}"
        found = template_for(prefixes, views.last, template_options)
        break found if found
      end
      break found if found
    end
    found or [nil, views]
  end

  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  # :nocov:
  def template_options_for(options = {})
    case options.fetch(:handler, nil)
    when :erb
      template_options_for_erb(options)
    when :slim
      template_options_for_slim(options)
    else
      super
    end
  end
  # :nocov:

  def template_options_for_erb(_options)
    {
      template_class: ::Cell::Erb::Template,
      suffix:         'erb',
      variant:        request_variant
    }.compact
  end

  def request_variant
    return if request.variant.blank?

    # :nocov:
    lookup_context = controller.lookup_context

    lookup_context.find_template(
      controller.rendered_template,
      lookup_context.prefixes
    ).variant
    # :nocov:
  end

  def template_options_for_slim(_options)
    {
      template_class: ::Slim::Template,
      suffix:         'slim',
      disable_escape: true,
      escape_code:    false,
      use_html_safe:  false,
      buffer:         '@output_buffer'
    }
  end

  delegate :controller_path, :current_user, :decorated_fc_user, :current_fc_profile, to: :controller

  # TODO: concernかhelperにする
  def format_period(str)
    year, month = str.split '-'
    format("%<year>s年#{'%<month>s月' if month}", year:, month:)
  end

  def testid(id)
    tag.span(data: { testid: id }) if ::Rails.env.test?
  end
end
