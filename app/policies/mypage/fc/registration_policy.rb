# frozen_string_literal: true

class Mypage::Fc::RegistrationPolicy < ApplicationPolicy
  def show?
    create?
  end

  def create?
    user.activated? && !user.registration_completed?
  end

  # TODO: #3353 不要なattributesの削除
  def permitted_attributes
    [
      :prefecture,
      :city,
      :building,
      :zipcode,
      :start_timing,
      :reward_min,
      :reward_desired,
      :occupancy_rate,
      :requests,
      :work_location1,
      :work_location2,
      :work_location3,
      :kakunin_bi,
      {
        experienced_works:     [],
        experienced_works_sub: [],
        desired_works:         [],
        desired_works_sub:     [],
        company_sizes:         [],
        business_form:         []
      }
    ]
  end
end
