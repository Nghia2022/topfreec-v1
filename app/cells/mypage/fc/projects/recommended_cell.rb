# frozen_string_literal: true

class Mypage::Fc::Projects::RecommendedCell < ApplicationCell
  include CategoryImages::ListHelpers

  # :nocov:
  cache :show, expires_in: 1.hour do
    cache_version = if FeatureSwitch.enabled?(:new_work_category)
                      :v2
                    else
                      :v1
                    end

    [
      cache_version,
      current_fc_user.account_cache_key_with_version,
      model.object.cache_key_with_version
    ]
  end
  # :nocov:

  def show
    render if model.present?
  end

  # :nocov:
  def home
    render
  end
  # :nocov:

  private

  def full_name
    current_fc_profile&.full_name
  end

  def render_projects
    render_items_with_image_index(ProjectCell, :recommended)
  end

  def slick_options
    {
      slidesToShow:   2,
      slidesToScroll: 2
    }.to_json
  end
end
