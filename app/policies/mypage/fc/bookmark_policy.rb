# frozen_string_literal: true

class Mypage::Fc::BookmarkPolicy < ApplicationPolicy
  def index?
    user.fc?
  end
end
