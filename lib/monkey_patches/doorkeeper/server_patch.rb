# frozen_string_literal: true

module Doorkeeper::ServerPatch
  # Doorkeeperは、クライアント認証として "client_secret_jwt" をサポートしていない。
  # commmuneでのOIDCの際には、"client_secret_jwt" が必要なのでpatchをあてた。
  def client
    if jwt_request?
      @client ||= Doorkeeper::OAuth::Client.authenticate(credentials, Doorkeeper.config.application_model.method(:by_jwt))
    else
      super
    end
  end

  private

  def jwt_request?
    parameters[:client_assertion].present? && parameters[:client_assertion_type].presence == 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer'
  end
end

Doorkeeper::Server.prepend(Doorkeeper::ServerPatch)
