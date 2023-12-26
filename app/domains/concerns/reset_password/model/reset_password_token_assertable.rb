# frozen_string_literal: true

module ResetPassword::Model
  module ResetPasswordTokenAssertable
    extend ActiveSupport::Concern

    class_methods do
      # disable :reek:FeatureEnvy
      def verify_reset_password_period(attributes = {})
        original_token = attributes[:reset_password_token]
        reset_password_token = Devise.token_generator.digest(self, :reset_password_token, original_token)

        recoverable = find_or_initialize_with_error_by(:reset_password_token, reset_password_token)

        recoverable.errors.add(:reset_password_token, :expired) if recoverable.persisted? && !recoverable.reset_password_period_valid?

        recoverable
      end
    end
  end
end
