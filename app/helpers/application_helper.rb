# frozen_string_literal: true

module ApplicationHelper
  def class_names(*)
    safe_join(build_tag_values(*), ' ')
  end

  def text_format(text)
    ERB::Util.html_escape(text).gsub(/\R/, '<br>')
  end

  def auto_paragraph(text)
    prepared_text = +text.to_s.gsub(/<!--.+?-->/, "\n&nbsp;\n")
    AutoParagraph.new.execute(prepared_text).strip
  end

  def active_menu(*start_paths_with, active_class: 'active')
    path_info = "#{request.path_info}/"
    active_class if match_any_paths(start_paths_with, path_info)
  end

  # :reek:DuplicateMethodCall, :reek:FeatureEnvy
  def merge_url_for(new_params = {})
    uri = URI.parse(request.original_url)
    params_for_merge = new_params.except(*ActionDispatch::Routing::RouteSet::RESERVED_OPTIONS)
    uri.query = Rack::Utils.parse_nested_query(uri.query || '').deep_symbolize_keys.merge(params_for_merge.deep_symbolize_keys).to_query
    if new_params[:only_path]
      # :nocov:
      "#{uri.path}?#{uri.query}"
      # :nocov:
    else
      uri.to_s
    end
  end

  private

  def match_any_paths(start_paths_with, path_info)
    start_paths_with.any? do |path|
      path_info =~ /\A#{path_with_slash(path)}/
    end
  end

  def path_with_slash(path)
    path.end_with?('/') ? path : "#{path}/"
  end

  def build_tag_values(*args)
    tag_values = []

    args.each do |tag_value|
      case tag_value
      when Hash
        tag_value.each do |key, val|
          tag_values << key if val
        end
      when Array
        # :nocov:
        tag_values << build_tag_values(*tag_value).presence
        # :nocov:
      else
        tag_values << tag_value.to_s if tag_value.present?
      end
    end

    tag_values.compact.flatten
  end

  # :nocov:
  # disable :reek:ControlParameter
  def link_to_block_if(condition, options = {}, html_options = {}, &)
    if condition
      link_to(options, html_options, &)
    else
      capture(&)
    end
  end
  # :nocov:

  def testid(id)
    tag.span(data: { testid: id }) if ::Rails.env.test?
  end
end
