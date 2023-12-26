# frozen_string_literal: true

class OauthSessionsController < ApplicationController
  def create
    self.oauth_email = auth_hash.info.email
    redirect_to admin_root_path, notice: 'ログインしました'
  end

  # :nocov:
  def destroy
    self.oauth_email = nil
    redirect_to admin_root_path, notice: 'ログアウトしました'
  end
  # :nocov:

  # :nocov:
  def failure
    redirect_to admin_root_path, alert: 'ログインできませんでした'
  end
  # :nocov:

  private

  def auth_hash
    request.env['omniauth.auth']
  end
end
