# frozen_string_literal: true

module Fc::UserActivation
  class FcUserActivationValidator < ActiveModel::Validator
    def validate(record)
      record.errors.add(:base, :already_activated) if record.activated_at_in_database.present?
    end
  end
end
