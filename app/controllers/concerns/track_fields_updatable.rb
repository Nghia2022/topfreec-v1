# frozen_string_literal: true

module TrackFieldsUpdatable
  extend ActiveSupport::Concern

  included do
    after_action :update_tracked_fields
  end

  private

  def update_tracked_fields
    current_user&.update_tracked_fields_if_necessary(request)
  end
end
