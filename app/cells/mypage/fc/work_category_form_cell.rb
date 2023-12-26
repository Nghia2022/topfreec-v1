# frozen_string_literal: true

class Mypage::Fc::WorkCategoryFormCell < ApplicationCell
  def show(&)
    render(&)
  end

  private

  def main_category_include?(main_category)
    selected_main_categories&.include?(main_category)
  end

  def work_categories
    @work_categories ||= WorkCategory.order(:name)
  end

  def selected_main_categories
    options.fetch(:selected_main_categories)
  end
end
