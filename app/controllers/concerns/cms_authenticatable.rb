# frozen_string_literal: true

module CmsAuthenticatable
  private

  def authenticate_wp_user!
    warden.authenticate!(scope: :wp_user)
  end
end
