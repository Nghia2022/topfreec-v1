# frozen_string_literal: true

module ErrorIndicationFormBuilder
  extend ActiveSupport::Concern

  include ActionView::Helpers::TagHelper
  include ActionView::Context

  def messages(attribute, options = {})
    item_tag = options.dig(:feedback, :item_tag) || :li
    item_options = options.dig(:feedback, :item_options) || {}

    safe_join(
      object.errors.full_messages_for(attribute).map do |message|
        content_tag(item_tag, message, *item_options)
      end
    )
  end

  # :reek:TooManyStatements
  def feedback(attribute, options = {})
    return unless options[:feedback] != false
    return if object.blank? || object.errors.messages[attribute].blank?

    container_tag = options.dig(:feedback, :container_tag) || :ul
    container_options = options.dig(:feedback, :container_options) || { class: 'form-row invalid-feedback c-red s-fc-01' }

    content_tag(container_tag, container_options) do
      messages(attribute, options)
    end
  end

  def text_field(attribute, options = {})
    super + feedback(attribute, options)
  end

  def email_field(attribute, options = {})
    super + feedback(attribute, options)
  end

  def password_field(attribute, options = {})
    super + feedback(attribute, options)
  end

  def text_area(attribute, options = {})
    super + feedback(attribute, options)
  end

  # rubocop:disable Metrics/ParameterLists
  def collection_radio_buttons(attribute, collection, value_method, text_method, options = {}, html_options = {}, &)
    super + feedback(attribute, options)
  end

  def collection_select(attribute, collection, value_method, text_method, options = {}, html_options = {})
    super + feedback(attribute, options)
  end

  def select(attribute, choices = nil, options = {}, html_options = {}, &)
    super(attribute, choices, options, html_options, &) + feedback(attribute, options)
  end
  # rubocop:enable Metrics/ParameterLists
end
