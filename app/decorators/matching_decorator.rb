# frozen_string_literal: true

class MatchingDecorator < Draper::Decorator
  delegate_all
  decorates_association :project

  delegate :project_name, to: :project, allow_nil: true
  delegate :compensation, to: :project, allow_nil: true

  def selection_status
    object.matching_status__c
  end

  def selection_status_for_fc
    case selection_status.to_sym
    when :candidate, :entry_target, :entry_completed
      :entry
    when :fc_declined_entry, :fc_declined_after_mtg
      :declined
    when :resume_submitted, :mtg_booked, :offer_contacted
      :proposed
    when :win
      :win
    when :fc_declining
      :declining
    else
      :closed
    end
  end

  def application_date
    object.createddate
  end
end
