# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/fc_user
class FcUserPreview < ActionMailer::Preview
  def confirmation_instructions
    record = FcUser.new(
      email:              'test@example.com',
      confirmation_token: token = 'token',
      contact:            Contact.of_all_fc.first,
      activated_at:       Time.zone.now
    )
    FcUserMailer.confirmation_instructions(record, token)
  end

  def reset_password_instructions
    record = FcUser.new(
      email:              'test@example.com',
      confirmation_token: token = 'token',
      contact:            Contact.of_all_fc.first
    )
    FcUserMailer.reset_password_instructions(record, token)
  end

  # def unlock_instructions
  #   record = FcUser.new(
  #     email:              'test@example.com',
  #     confirmation_token: token = 'token'
  #   )
  #   FcUserMailer.unlock_instructions(record, token)
  # end
  #
  def email_changed
    record = FcUser.new(
      email: 'test@example.com'
    )
    FcUserMailer.email_changed(record)
  end

  def password_change
    record = FcUser.new(
      email:   'test@example.com',
      contact: Contact.of_all_fc.first
    )
    FcUserMailer.password_change(record)
  end

  def activatoin_instructions
    record = Fc::UserActivation::FcUser.new(
      email:            'test@example.com',
      activation_token: Devise.friendly_token,
      contact:          Contact.of_all_fc.first
    )
    FcUserMailer.activation_instructions(fc_user: record, activation_token: record.activation_token)
  end
end
