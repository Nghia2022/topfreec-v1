# frozen_string_literal: true

class Mypage::Fc::Settings::DesiredConditionPolicy < ApplicationPolicy
  def edit?
    update?
  end

  def update?
    user.fc? && record.owner?(user)
  end

  # TODO: #3353 不要なパラメータの削除
  def permitted_attributes
    [
      :work_location1,
      :work_location2,
      :work_location3,
      {
        business_form:     [],
        experienced_works: [],
        desired_works:     [],
        company_sizes:     []
      }
    ]
  end
end
