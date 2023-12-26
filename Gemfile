# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.0.7'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 6.3'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
# gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.11'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

group :development do
  gem 'html2slim'
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.9'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'active_record_query_trace'
  gem 'erbcop'
  gem 'lineprof', require: false
  gem 'reek', require: false
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
end

group :test do
  gem 'email_spec'
  gem 'named_let'
  gem 'pundit-matchers', '~> 3.1.2'
  gem 'rspec-json_matcher', github: 'whiteleaf7/rspec-json_matcher'
  gem 'rspec-parameterized'
  gem 'rspec-retry'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'test-prof'
  gem 'vcr'
  gem 'webmock'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

gem 'aasm'
gem 'active_hash'
gem 'activejob-uniqueness'
gem 'active_model_serializers', '~> 0.10.13'
gem 'active_type'
gem 'after_commit_everywhere'
gem 'aws-sdk-s3'
gem 'newrelic_rpm'

gem 'apipie-rails'
gem 'attr_encrypted'
gem 'auto_paragraph'
gem 'batch-loader'
gem 'blazer'
gem 'blueprinter'
gem 'breadcrumbs_on_rails'
gem 'cells', github: 'trailblazer/cells'
gem 'cells-erb'
gem 'cells-rails'
gem 'cells-slim'
gem 'cloudinary'
gem 'config'
gem 'devise'
gem 'devise-encryptable'
gem 'devise-i18n'
gem 'devise-security'
gem 'doorkeeper'
gem 'doorkeeper-openid_connect'
gem 'draper'
gem 'enumerize'
gem 'flipper'
gem 'flipper-active_record'
gem 'flipper-ui'
gem 'hairtrigger'
gem 'httparty'
gem 'impressionist', github: 'charlotte-ruby/impressionist'
gem 'jp_prefecture'
gem 'jsbundling-rails'
gem 'kaminari'
gem 'kaminari-cells'
gem 'letter_opener_web', '~> 2.0'
gem 'material_icons'
gem 'meta-tags'
gem 'mysql2'
gem 'naught'
gem 'omniauth-oauth2'
gem 'omniauth-rails_csrf_protection'
gem 'omniauth-salesforce', github: 'ruffnote/omniauth-salesforce'
gem 'parallel'
gem 'phony_rails'
gem 'phpass-ruby', require: 'phpass'
gem 'pundit'
gem 'rack-dev-mark'
gem 'rails_admin'
gem 'rails_admin-i18n'
gem 'rails-i18n'
gem 'recaptcha'
gem 'redis-session-store'
gem 'restforce', '~> 6.2.1'
gem 'rexml'
gem 'scenic'
gem 'seed-fu'
gem 'sidekiq'
gem 'sidekiq-scheduler'
gem 'slim-rails'
gem 'strip_attributes'
gem 'switch_user'
gem 'trend'
gem 'twilio-ruby', '~> 5.48.0'
gem 'two_factor_authentication', github: 'mirai-sys/two_factor_authentication'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'annotate'
  gem 'bullet'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'capybara'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'ridgepole'
  gem 'rspec-cells'
  gem 'rspec_junit_formatter'
  gem 'rspec-rails'
  gem 'rspec-request_describer'
  gem 'shoulda-matchers'
end

gem 'factory_bot_rails'
gem 'faker'
gem 'faker-japanese'
gem 'sassc-rails'
