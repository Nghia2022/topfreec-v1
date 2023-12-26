# frozen_string_literal: true

# ref: https://blog.naichilab.com/entry/2016/01/15/013321
Rails.application.config.action_view.field_error_proc = proc do |html_tag, _instance|
  # rubocop:disable Rails/OutputSafety
  html_tag.to_s.html_safe
  # rubocop:enable Rails/OutputSafety
end
