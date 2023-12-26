# frozen_string_literal: true

class WelcomeController < ApplicationController
  include TopicsDisplayable

  before_action :redirect_to_mypage, only: %i[index]

  def index; end

  private

  def redirect_to_mypage
    redirect_to mypage_client_root_path if current_user.is_a? ClientUser
  end

  def projects_featured
    @projects_featured ||= Project.published.featured_order.limit(8).decorate
  end
  helper_method :projects_featured

  def projects_new_arrivals
    @projects_new_arrivals ||= Project.published.new_arrival.limit(8).decorate
  end
  helper_method :projects_new_arrivals

  def work_locations
    @work_locations ||= DesiredCondition.work_location1.values
  end
  helper_method :work_locations

  def categories
    # TODO: #3440 FeatureSwitchの分岐を削除
    @categories ||= if FeatureSwitch.enabled?(:new_project_category_meta)
                      Project::ExperienceCategory.includes(:project_category_metum)
                      # :nocov:
                    else
                      Project::ExperienceCategory.all
                      # :nocov:
                    end
  end
  helper_method :categories

  concerning :Meta do
    protected

    def build_meta(_options)
      super
      build_ogp
      build_twitter_card
    end
  end
end
