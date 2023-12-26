# frozen_string_literal: true

module Materializable
  extend ActiveSupport::Concern

  class_methods do
    def refresh(params = { concurrently: true })
      Scenic.database.refresh_materialized_view(table_name, **params)
    end
  end

  # :nocov:
  def readonly?
    true
  end
  # :nocov:
end
