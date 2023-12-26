# frozen_string_literal: true

class Mypage::Client::BookmarkPolicy < ApplicationPolicy
  def index?
    user.client?
  end
end
