# frozen_string_literal: true

class Projects::EntryPolicy < ApplicationPolicy
  def create?
    [
      user.fc?,
      user.activated?,
      !project.entry_closed?,
      !project.effective_entries.exists?(account: user.account)
    ].all?
  end

  def permitted_attributes
    %i[start_timing reward_min reward_desired occupancy_rate]
  end

  delegate :project, to: :record, allow_nil: true
end
