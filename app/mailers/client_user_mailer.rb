# frozen_string_literal: true

class ClientUserMailer < Devise::Mailer
  before_action :set_i18n_scope, only: %i[
    confirmation_instructions
    reset_password_instructions
    unlock_instructions
    email_changed
    password_change
  ]

  default from: Settings.mailer.from

  def reset_password_instructions(record, token, opts = {})
    @profile = ProfileDecorator.decorate(record.contact.to_sobject)
    super
  end

  # def reset_password_instructions(record, token, opts={})
  #   super
  # end

  # def unlock_instructions(record, token, opts={})
  #   super
  # end

  # def email_changed(record, opts={})
  #   super
  # end

  def password_change(record, opts = {})
    @profile = ProfileDecorator.decorate(record.contact.to_sobject)
    super
  end

  private

  def set_i18n_scope
    @i18n_scope = "devise.mailer.#{action_name}"
  end
end
