# frozen_string_literal: true

if Rails.env.development?
  class LocaleReloader
    def initialize(app)
      @app = app

      yaml_files = Dir.glob('config/locales/**/*.yml')
      Rails.logger.info 'LocaleReloader'
      @locale_reloader = ActiveSupport::FileUpdateChecker.new(yaml_files) do
        I18n.reload!
      end
    end

    def call(env)
      @locale_reloader.execute_if_updated
      @app.call(env)
    end
  end

  Rails.application.config.middleware.use LocaleReloader
end
