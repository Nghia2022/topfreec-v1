# frozen_string_literal: true

class AuthenticateAdminConstraint
  include OauthAuthenticatable::InstanceMethods

  def matches?(request)
    self.request = request
    authenticated?
  end

  private

  attr_accessor :request

  delegate :session, to: :request

  def authenticated?
    admin_signed_in? || Rails.env.development?
  end
end
