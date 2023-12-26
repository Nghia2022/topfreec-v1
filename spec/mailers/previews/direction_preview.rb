# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/direction
class DirectionPreview < ActionMailer::Preview
  def notify_confirmation_request_to_client
    DirectionMailer.notify_confirmation_request_to_client(direction)
  end

  def notify_auto_approved_by_client
    DirectionMailer.notify_auto_approved_by_client(direction)
  end

  def notify_confirmation_completed_to_client
    DirectionMailer.notify_confirmation_completed_to_client(direction)
  end

  def notify_confirmation_request_to_fc
    DirectionMailer.notify_confirmation_request_to_fc(direction)
  end

  def notify_modification_request_to_client
    presenter = Client::ManageDirection::DirectionMailerPresenterBuilder.from_direction(
      ActiveType.cast(direction, Client::ManageDirection::Direction)
    )
    DirectionMailer.notify_modification_request_to_client(direction, authorizer_of_client_full_name: presenter.main_cl_contact_fullname)
  end

  def notify_confirmation_completed_to_fc
    DirectionMailer.notify_confirmation_completed_to_fc(direction)
  end

  def notify_modification_request_to_fc
    presenter = Fc::ManageDirection::DirectionMailerPresenterBuilder.from_direction(
      ActiveType.cast(direction, Fc::ManageDirection::Direction)
    )
    DirectionMailer.notify_modification_request_to_fc(direction, modification_requester_of_fc_full_name: presenter.main_fc_contact_fullname)
  end

  def notify_auto_approved_by_fc
    DirectionMailer.notify_auto_approved_by_fc(direction)
  end

  def notify_reconfirmation_request_to_fc
    DirectionMailer.notify_reconfirmation_request_to_fc(direction)
  end

  def notify_reconfirmation_request_to_client
    DirectionMailer.notify_reconfirmation_request_to_client(direction)
  end

  private

  def direction
    Direction.first
  end
end
