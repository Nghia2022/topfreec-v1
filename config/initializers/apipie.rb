# frozen_string_literal: true

Apipie.configure do |config|
  config.app_name                = 'Freeconsultant.jp'
  config.api_base_url['v1']      = '/api/v1'
  config.doc_base_url            = '/apidoc'
  config.default_version         = 'v1'
  config.translate               = false
  config.show_all_examples       = false
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/**/*.rb"
  config.default_locale = :ja
  config.namespaced_resources = true
end
