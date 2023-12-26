# frozen_string_literal: true

class WpUsers::SessionsController < ApplicationController
  http_basic_authenticate_with name: ENV.fetch('WP_BASIC_AUTH_USERNAME', nil), password: ENV.fetch('WP_BASIC_AUTH_PASSWORD', nil) if ENV.key?('WP_BASIC_AUTH_USERNAME') && ENV.key?('WP_BASIC_AUTH_PASSWORD')

  layout 'cms/application'

  def new; end

  def create
    resource = warden.authenticate!(scope: :wp_user)
    flash[:notice] = :signed_in
    sign_in(:wp_user, resource)
    redirect_to cms_root_path
  end

  def destroy
    sign_out(:wp_user)
    flash[:notice] = :signed_out
    redirect_to new_wp_user_session_path
  end

  private

  def wp_user
    WpUsers::SignIn.new
  end
  helper_method :wp_user
end
