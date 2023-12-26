# frozen_string_literal: true

module ResetPassword::Controller
  module ResetPasswordTokenAssertable
    extend ActiveSupport::Concern

    def assert_reset_token_passed
      super

      self.resource = resource_class.verify_reset_password_period(params)
      return unless reset_password_token_expired?

      set_flash_message(:alert, :expired)
      redirect_to new_password_path(resource)
    end

    # disable :reek:DuplicateMethodCall
    def reset_password_token_expired?
      resource.errors.added?(:reset_password_token, :expired) || resource.errors.added?(:reset_password_token, :invalid)
    end
  end
end
