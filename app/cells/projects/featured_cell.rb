# frozen_string_literal: true

class Projects::FeaturedCell < ApplicationCell
  include CategoryImages::ListHelpers

  def home
    render
  end

  def mypage
    render
  end

  def detail
    render
  end

  private

  def render_projects
    render_items_with_image_index(ProjectCell, :featured)
  end

  def slick_options
    {
      slidesToShow:   4,
      slidesToScroll: 4,
      responsive:     [
        {
          breakpoint: 1199,
          settings:   {
            arrows:         false,
            slidesToShow:   3,
            slidesToScroll: 3
          }
        },
        {
          breakpoint: 1024,
          settings:   {
            arrows:         false,
            slidesToShow:   3,
            slidesToScroll: 3
          }
        },
        {
          breakpoint: 768,
          settings:   {
            arrows:         false,
            slidesToShow:   1,
            slidesToScroll: 1
          }
        }
      ]
    }.to_json
  end
end
