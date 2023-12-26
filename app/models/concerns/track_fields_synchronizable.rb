# frozen_string_literal: true

module TrackFieldsSynchronizable
  def update_tracked_fields_if_necessary(request)
    return if Time.current.all_day.cover?(current_sign_in_at)

    update_tracked_fields!(request)
  end

  def update_tracked_fields(request)
    super
    assign_attributes(user_agent: request.user_agent.to_s)

    contact&.update(fcweb_logindatetime__c: current_sign_in_at) if will_save_change_to_current_sign_in_at?
  end
end
