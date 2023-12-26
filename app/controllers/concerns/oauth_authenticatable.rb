# frozen_string_literal: true

module OauthAuthenticatable
  extend ActiveSupport::Concern

  included do
    include InstanceMethods

    helper_method :admin_signed_in?
  end

  module InstanceMethods
    private

    def oauth_email
      session[:oauth_email]
    end

    def oauth_email=(email)
      session[:oauth_email] = email
    end

    def admin_signed_in?
      # TODO: admin判断ロジック
      oauth_email.to_s =~ /@(mirai-works\.co\.jp|ruffnote\.com)\z/
    end

    # :nocov:
    def authenticate_admin!
      return if admin_signed_in?

      raise ActiveRecord::RecordNotFound
    end
    # :nocov:
  end
end
