# frozen_string_literal: true

# :reek:TooManyMethods
class MatchingMailer < ApplicationMailer
  def notify_candidate_to_fc(matching)
    @presenter = matching_presenter(matching)

    build_message
  end

  def notify_fc_declined_entry_to_fc(matching)
    @presenter = matching_presenter(matching)

    build_message
  end

  def notify_not_eligible_for_entry_to_fc(matching)
    @presenter = matching_presenter(matching)

    build_message
  end

  def notify_client_ng_after_resume_submitted_to_fc(matching)
    @presenter = matching_presenter(matching)

    build_message
  end

  def notify_fc_declining_to_fc(matching)
    @presenter = matching_presenter(matching)

    build_message
  end

  def notify_fc_declined_after_mtg_to_fc(matching)
    @presenter = matching_presenter(matching)

    build_message
  end

  def notify_lost_candidate_to_fc(matching)
    @presenter = matching_presenter(matching)

    build_message
  end

  def notify_lost_entry_target_to_fc(matching)
    @presenter = matching_presenter(matching)

    build_message
  end

  def notify_lost_entry_completed_to_fc(matching)
    @presenter = matching_presenter(matching)

    build_message
  end

  def notify_lost_resume_submitted_to_fc(matching)
    @presenter = matching_presenter(matching)

    build_message
  end

  private

  attr_reader :presenter

  helper_method :presenter

  def matching_presenter(matching)
    Fc::Entry::MatchingMailerPresenterBuilder.from_matching(matching)
  end

  def build_message
    payload = {
      subject: i18n_subject(project_id: presenter.project_id),
      from:    presenter.email_from,
      to:      presenter.email_to,
      cc:      presenter.email_cc
    }

    mail payload
  end
end
