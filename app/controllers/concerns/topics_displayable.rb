# frozen_string_literal: true

module TopicsDisplayable
  extend ActiveSupport::Concern

  included do
    helper_method :topics
  end

  def topics
    @topics ||= Wordpress::Topic
                .news
                .page(params[:page])
                .per(4)
  end
end
