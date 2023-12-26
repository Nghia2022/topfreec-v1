# frozen_string_literal: true

# https://github.com/rails/rails/pull/33145
# 許可ホストを環境変数から追加
Rails.application.config.hosts += ENV['HOSTS_WHITELIST'].split(',') if ENV['HOSTS_WHITELIST'].present? && Rails.env.development?
