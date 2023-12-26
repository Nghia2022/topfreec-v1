# frozen_string_literal: true

class Mypage::Fc::BookmarksController < Mypage::Fc::BaseController
  Bookmark = Struct.new('FcBookmark', :project_name, :project_id, :created_at)
  before_action :set_bookmarks

  def index; end

  private

  def set_bookmarks
    bookmarks = 1.upto(50).map do |id|
      bookmark = Bookmark.new
      bookmark.project_name = "Fake Project #{id}"
      bookmark.project_id = id
      bookmark.created_at = Time.current
      bookmark
    end

    @bookmarks = Kaminari.paginate_array(bookmarks).page(page_param)
    authorize @bookmarks, policy_class: Mypage::Fc::BookmarkPolicy
  end
end
