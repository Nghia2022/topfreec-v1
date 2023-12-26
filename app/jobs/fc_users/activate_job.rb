# frozen_string_literal: true

class FcUsers::ActivateJob < ApplicationJob
  queue_as :default
  unique :until_expired, lock_ttl: 1.minute, on_conflict: :log

  retry_on Fc::UserActivation::ContactNotFound, attempts: 10, wait: :exponentially_longer

  def perform(lead_no, contact_sfid)
    user = Fc::UserActivation::FcUser.find_or_initialize_by(lead_no:)
    user.send_activation contact_sfid
  end

  def retry_job(options = {})
    self.class.unlock!(*arguments)
    super
  end

  def retry_stopped(error)
    raise Fc::UserActivation::RetryStopped, error
  end
end
