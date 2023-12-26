# frozen_string_literal: true

class DirectionMailer < ApplicationMailer
  def notify_confirmation_request_to_client(direction)
    @presenter = client_presenter(direction)

    build_message
  end

  def notify_reconfirmation_request_to_client(direction)
    @presenter = client_presenter(direction)

    build_message
  end

  def notify_auto_approved_by_client(direction)
    @presenter = client_presenter(direction)

    build_message
  end

  def notify_modification_request_to_client(direction, authorizer_of_client_full_name:)
    @presenter = client_presenter(direction).tap do |this|
      this.authorizer_of_client_full_name = authorizer_of_client_full_name
    end

    build_message
  end

  def notify_confirmation_completed_to_client(direction)
    @presenter = client_presenter(direction)

    build_message
  end

  def notify_confirmation_request_to_fc(direction)
    @presenter = fc_presenter(direction)

    build_message
  end

  def notify_confirmation_completed_to_fc(direction)
    @presenter = fc_presenter(direction)

    build_message
  end

  def notify_modification_request_to_fc(direction, modification_requester_of_fc_full_name:)
    @presenter = fc_presenter(direction).tap do |this|
      this.modification_requester_of_fc_full_name = modification_requester_of_fc_full_name
    end

    build_message
  end

  def notify_auto_approved_by_fc(direction)
    @presenter = fc_presenter(direction)

    build_message
  end

  attr_reader :presenter

  helper_method :presenter

  private

  def client_presenter(direction)
    Client::ManageDirection::DirectionMailerPresenterBuilder.from_direction(
      ActiveType.cast(direction, Client::ManageDirection::Direction)
    )
  end

  def fc_presenter(direction)
    Fc::ManageDirection::DirectionMailerPresenterBuilder.from_direction(
      ActiveType.cast(direction, Fc::ManageDirection::Direction)
    )
  end

  def build_message
    payload = {
      subject: i18n_subject,
      from:    presenter.email_from,
      to:      presenter.email_to,
      cc:      presenter.email_cc,
      bcc:     presenter.email_bcc
    }

    mail payload
  end
end
