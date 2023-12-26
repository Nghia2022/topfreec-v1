# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_mailbox/engine'
require 'action_text/engine'
require 'action_view/railtie'
require 'sprockets/railtie'
# require "rails/test_unit/railtie"

impressionist_dir = Gem::Specification.find_by_name('impressionist').gem_dir
require File.join(impressionist_dir, '/app/controllers/impressionist_controller.rb')

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require_relative '../app/middlewares/invalid_path_blocker'

module App
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    config.active_record.has_many_inversing = false
    config.time_zone = 'Tokyo'

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Don't generate system test files.
    config.generators.system_tests = nil

    config.generators do |generator|
      generator.cell parent: 'ApplicationCell'
      generator.javascripts false
      generator.stylesheets false
      generator.helper false
      generator.test_framework :rspec,
                               fixtures:         true,
                               view_specs:       false,
                               helper_specs:     false,
                               routing_specs:    false,
                               controller_specs: false,
                               request_specs:    true
      generator.fixture_replacement :factory_bot, dir: 'spec/factories'
    end

    config.i18n.default_locale = :ja
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.active_model.i18n_customize_full_message = true

    config.active_record.yaml_column_permitted_classes = [
      Symbol,
      ActiveSupport::HashWithIndifferentAccess
    ]

    config.read_encrypted_secrets = true

    config.middleware.use BatchLoader::Middleware
    config.middleware.use InvalidPathBlocker

    config.action_dispatch.rescue_responses['ActiveHash::RecordNotFound'] = :not_found

    #
    # Customize the env string (default Rails.env)
    # config.rack_dev_mark.env = 'foo'
    #
    # Customize themes if you want to do so
    # config.rack_dev_mark.theme = [:title, :github_fork_ribbon]
    #
    # Customize inserted place of the middleware if necessary.
    # You can use either `insert_before` or `insert_after`
    # config.rack_dev_mark.insert_before SomeOtherMiddleware
    # config.rack_dev_mark.insert_after SomeOtherMiddleware

    # Enable rack-dev-mark
    config.rack_dev_mark.enable = !Rails.env.production?

    colors = {
      development: 'green',
      staging:     'red'
    }
    ribbon_color = ENV.key?('HEROKU_BRANCH') ? 'orange' : colors[Rails.env.to_sym]

    config.rack_dev_mark.env = ENV.fetch('HEROKU_BRANCH') { Rails.env }
    config.rack_dev_mark.theme = [:title, Rack::DevMark::Theme::GithubForkRibbon.new(position: 'right', fixed: true, color: ribbon_color)]

    config.active_job.queue_adapter = :sidekiq

    # アプリケーション内の設定値（default）
    #
    # 各環境で別の値を設定する場合は、config/environments/*.rb で上書きします

    config.x.default_url_options.protocol = 'https'
    config.x.default_url_options.host = 'freeconsultant.jp'
  end
end
