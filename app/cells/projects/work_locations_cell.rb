# frozen_string_literal: true

class Projects::WorkLocationsCell < ApplicationCell
  def show
    render
  end

  def work_locations
    model
  end
end
