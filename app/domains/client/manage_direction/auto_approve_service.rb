# frozen_string_literal: true

module Client::ManageDirection
  class AutoApproveService
    include Service

    def call
      directions.each do |direction|
        direction.auto_approve_by_client!
      rescue StandardError => e
        # :nocov:
      end
    end

    private

    def directions
      @directions ||= DirectionAutoApproveQuery.call(relation: Direction.all, date: Date.current)
    end
  end
end
