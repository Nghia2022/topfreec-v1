# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/client_user
class ClientUserPreview < ActionMailer::Preview
  def confirmation_instructions
    record = ClientUser.new(
      email:              'test@example.com',
      confirmation_token: token = 'token'
    )
    ClientUserMailer.confirmation_instructions(record, token)
  end

  def reset_password_instructions
    record = ClientUser.new(
      email:              'test@example.com',
      confirmation_token: token = 'token',
      contact:            Contact.of_client.first
    )
    ClientUserMailer.reset_password_instructions(record, token)
  end

  # def unlock_instructions
  #   record = ClientUser.new(
  #     email:              'test@example.com',
  #     confirmation_token: token = 'token'
  #   )
  #   ClientUserMailer.unlock_instructions(record, token)
  # end
  #
  def email_changed
    record = ClientUser.new(
      email: 'test@example.com'
    )
    ClientUserMailer.email_changed(record)
  end

  def password_change
    record = ClientUser.new(
      email:   'test@example.com',
      contact: Contact.of_client.first
    )
    ClientUserMailer.password_change(record)
  end
end
