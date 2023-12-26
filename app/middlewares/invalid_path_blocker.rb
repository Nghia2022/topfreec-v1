# frozen_string_literal: true

class InvalidPathBlocker
  SANITIZE_ENV_KEYS = %w[
    HTTP_REFERER
    PATH_INFO
    REQUEST_URI
    REQUEST_PATH
    QUERY_STRING
  ].freeze

  def initialize(app)
    self.app = app
  end

  def call(env)
    SANITIZE_ENV_KEYS.each do |key|
      next if decode_path(env, key).valid_encoding?

      return [400, {}, ['Bad request']]
    end

    app.call(env)
  end

  private

  attr_accessor :app

  def decode_path(env, key)
    CGI.unescape(env[key].to_s).force_encoding(Encoding::UTF_8)
  end
end
