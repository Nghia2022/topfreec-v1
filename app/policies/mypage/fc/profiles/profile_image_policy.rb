# frozen_string_literal: true

class Mypage::Fc::Profiles::ProfileImagePolicy < ApplicationPolicy
  def permitted_attributes
    %i[profile_image]
  end
end
