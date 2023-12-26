# frozen_string_literal: true

class LandingPagePolicy < ApplicationPolicy
  def permitted_attributes
    %i[email last_name first_name last_name_kana first_name_kana phone work_area1 work_area2 work_area3]
  end
end
