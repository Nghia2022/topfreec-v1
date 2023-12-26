# frozen_string_literal: true

class Content::TopicsController < Content::ApplicationController
  layout 'welcome'

  def index; end

  private

  def topics
    @topics ||= Wordpress::Topic
                .news
                .page(params[:page])
                .per(20)
  end
  helper_method :topics

  concerning :Breadcrumbs do
    def build_breadcrumbs(_options)
      add_breadcrumb 'TOP', :root_path
      add_breadcrumb 'News'
    end
  end
end
