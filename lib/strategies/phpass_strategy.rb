# frozen_string_literal: true

module Warden::Strategies
  # disable :reek:IrresponsibleModule, :reek:MissingSafeMethod
  class PhpassStrategy < ::Warden::Strategies::Base
    def valid?
      params.fetch(scope, {}).fetch('password', nil)
    end

    # disable :reek:DuplicateMethodCall
    def authenticate!
      user = Wordpress::WpUser.find_for_authentication(params[scope].slice('user_login'))
      if user&.valid_password?(params[scope]['password'])
        success!(user)
      else
        fail!('storagegies.phpass.failed')
      end
    end
  end
end

Warden::Strategies.add(:phpass, Warden::Strategies::PhpassStrategy)
