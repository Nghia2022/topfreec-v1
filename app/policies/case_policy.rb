# frozen_string_literal: true

class CasePolicy < ApplicationPolicy
  def permitted_attributes
    %i[last_name first_name last_name_kana first_name_kana email email_confirmation phone description case_type confirming]
  end
end
