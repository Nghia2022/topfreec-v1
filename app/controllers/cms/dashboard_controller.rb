# frozen_string_literal: true

class Cms::DashboardController < Cms::ApplicationController
  include CmsAuthenticatable

  before_action :authenticate_wp_user!

  def index; end

  private

  def drafts
    @drafts = Wordpress::WpPost.supported_post_types.draft
                               .page(page_param).per(per_page_param)
  end
  helper_method :drafts
end
