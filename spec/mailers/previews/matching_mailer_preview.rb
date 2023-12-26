# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/matching_mailer
class MatchingMailerPreview < ActionMailer::Preview
  def notify_candidate_to_fc
    MatchingMailer.notify_candidate_to_fc(matching)
  end

  def notify_fc_declined_entry_to_fc
    MatchingMailer.notify_fc_declined_entry_to_fc(matching)
  end

  def notify_not_eligible_for_entry_to_fc
    MatchingMailer.notify_not_eligible_for_entry_to_fc(matching)
  end

  def notify_client_ng_after_resume_submitted_to_fc
    MatchingMailer.notify_client_ng_after_resume_submitted_to_fc(matching)
  end

  def notify_fc_declining_to_fc
    MatchingMailer.notify_fc_declining_to_fc(matching)
  end

  def notify_fc_declined_after_mtg_to_fc
    MatchingMailer.notify_fc_declined_after_mtg_to_fc(matching)
  end

  def notify_lost_candidate_to_fc
    MatchingMailer.notify_lost_candidate_to_fc(matching)
  end

  def notify_lost_entry_target_to_fc
    MatchingMailer.notify_lost_entry_target_to_fc(matching)
  end

  def notify_lost_entry_completed_to_fc
    MatchingMailer.notify_lost_entry_completed_to_fc(matching)
  end

  def notify_lost_resume_submitted_to_fc
    MatchingMailer.notify_lost_resume_submitted_to_fc(matching)
  end

  private

  def matching
    Matching.last
  end
end
