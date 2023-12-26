# frozen_string_literal: true

class Oauth::OpenidConnect::DiscoveryController < Doorkeeper::OpenidConnect::DiscoveryController
  private

  def provider_response
    {
      **super,
      token_endpoint_auth_methods_supported: %w[client_secret_basic client_secret_post client_secret_jwt]
    }
  end

  def issuer
    protocol = Doorkeeper::OpenidConnect.configuration.protocol.call(request)
    "#{protocol}://#{request.host_with_port}"
  end
end
