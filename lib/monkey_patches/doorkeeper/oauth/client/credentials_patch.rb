# frozen_string_literal: true

module Doorkeeper::OAuth::Client::CredentialsPatch
  # Doorkeeperは、クライアント認証として "client_secret_jwt" をサポートしていない。
  # commmuneでのOIDCの際には、"client_secret_jwt" が必要なのでpatchをあてた。
  # config/initializers/doorkeeper.rb に `client_credentials :from_jwt` を追加する必要がある。
  # :reek:UtilityFunction
  def from_jwt(request)
    request.parameters.values_at(:client_id, :client_assertion)
  end
end

Doorkeeper::OAuth::Client::Credentials.singleton_class.prepend(Doorkeeper::OAuth::Client::CredentialsPatch)
