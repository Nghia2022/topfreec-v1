# frozen_string_literal: true

class Admin::ApplicationController < ApplicationController
  before_action :authenticate_admin!

  http_basic_authenticate_with name: ENV.fetch('ADMIN_BASIC_AUTH_USERNAME', nil), password: ENV.fetch('ADMIN_BASIC_AUTH_PASSWORD', nil) if ENV.key?('ADMIN_BASIC_AUTH_USERNAME') && ENV.key?('ADMIN_BASIC_AUTH_PASSWORD')
end
