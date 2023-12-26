# frozen_string_literal: true

# disable :reek:FeatureEnvy
module CellHelpers
  # disable :reek:DuplicateMethodCall, :reek:TooManyStatements
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def with_request_url(path)
    request = controller.request
    old_request_path_info = request.path_info
    old_request_path_parameters = request.path_parameters
    old_request_query_parameters = request.query_parameters
    old_request_query_string = request.query_string
    old_controller = defined?(@controller) && @controller

    request.path_info = path
    request.path_parameters = Rails.application.routes.recognize_path(path)
    controller.action_name = request.path_parameters[:action]
    request.set_header('action_dispatch.request.query_parameters', Rack::Utils.parse_nested_query(path.split('?')[1]))
    request.set_header(Rack::QUERY_STRING, path.split('?')[1])
    yield
  ensure
    request.path_info = old_request_path_info
    request.path_parameters = old_request_path_parameters
    request.set_header('action_dispatch.request.query_parameters', old_request_query_parameters)
    request.set_header(Rack::QUERY_STRING, old_request_query_string)
    @controller = old_controller
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # disable :reek:DuplicateMethodCall
  def with_prefixes(prefixes)
    old_prefixes = controller.lookup_context.prefixes
    controller.lookup_context.prefixes = prefixes
    yield
  ensure
    controller.lookup_context.prefixes = old_prefixes
  end

  # disable :reek:DuplicateMethodCall
  def with_variant(*variant)
    old_variant = controller.request.variant
    variants = variant.compact
    controller.request.variant = variants
    controller.lookup_context.variants = variants
    yield
  ensure
    controller.request.variant = old_variant
  end

  def with_template(template)
    old_template = controller.rendered_template
    controller.instance_variable_set(:@rendered_template, template)
    yield
  ensure
    controller.instance_variable_set(:@rendered_template, old_template)
  end

  # disable :reek:LongParameterList
  def with_request(path:, prefixes:, variant:, template:, &block)
    with_request_url(path) do
      with_prefixes(prefixes) do
        with_variant(variant) do
          with_template(template, &block)
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include CellHelpers, type: :cell
end
