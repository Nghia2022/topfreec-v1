# frozen_string_literal: true

class Content::ApplicationController < ApplicationController
  layout 'content/application'

  protected

  def recruiting_projects
    @recruiting_projects ||= Project.published.new_arrival.limit(4)
  end

  helper_method :recruiting_projects
end
