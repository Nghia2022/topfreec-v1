# frozen_string_literal: true

# disable :reek:TooManyInstanceVariables
class FcUserMailer < Devise::Mailer
  before_action :set_i18n_scope, only: %i[
    confirmation_instructions
    reset_password_instructions
    unlock_instructions
    email_changed
    password_change
  ]

  default from: Settings.mailer.from

  def confirmation_instructions(record, token, _opts = {})
    @fc_user = record
    @token = token
    @profile = ProfileDecorator.decorate(@fc_user.account.to_sobject) if @fc_user.activated?
    mail to: @fc_user.unconfirmed_email || @fc_user.email, subject: I18n.t('confirmation_instructions.subject', scope: 'mailers.fc_user_mailer')
  end

  def reset_password_instructions(record, token, opts = {})
    @profile = ProfileDecorator.decorate(record.contact.to_sobject)
    super(record, token, opts.merge(subject: I18n.t('reset_password_instructions.subject', scope: 'mailers.fc_user_mailer')))
  end

  # def unlock_instructions(record, token, opts={})
  #   super
  # end

  # def email_changed(record, opts={})
  #   super
  # end

  def password_change(record, opts = {})
    @profile = ProfileDecorator.decorate(record.contact.to_sobject)
    super(record, opts.merge(subject: I18n.t('password_change.subject', scope: 'mailers.fc_user_mailer')))
  end

  def activation_instructions(fc_user:, activation_token:)
    account = Salesforce::Account.find(fc_user.contact.accountid)
    @fc_user = fc_user
    @token = activation_token
    @profile = ProfileDecorator.decorate(account)
    mail to: @fc_user.email, subject: I18n.t('activation_instructions.subject', scope: 'mailers.fc_user_mailer')
  end

  private

  def set_i18n_scope
    @i18n_scope = "devise.mailer.#{action_name}"
  end
end
