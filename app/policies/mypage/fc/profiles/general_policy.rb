# frozen_string_literal: true

class Mypage::Fc::Profiles::GeneralPolicy < ApplicationPolicy
  def edit?
    update?
  end

  def update?
    user.fc?
  end

  def permitted_attributes
    %i[
      phone
      phone2
      prefecture
      city
      building
      zipcode
    ]
  end
end
