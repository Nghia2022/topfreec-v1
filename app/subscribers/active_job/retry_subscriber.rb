# frozen_string_literal: true

class ActiveJob::RetrySubscriber < ActiveSupport::Subscriber
  # :reek:ManualDispatch, :reek:UtilityFunction
  def retry_stopped(event)
    job, error = event.payload.values_at(:job, :error)

    job.retry_stopped(error) if job.respond_to?(:retry_stopped)
  end
end

ActiveJob::RetrySubscriber.attach_to :active_job
