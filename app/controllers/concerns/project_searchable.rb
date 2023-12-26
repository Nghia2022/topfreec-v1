# frozen_string_literal: true

module ProjectSearchable
  extend ActiveSupport::Concern

  included do
    helper_method :search_form
  end

  def search_form
    @search_form ||= Projects::SearchForm.new(
      { recruiting: user_signed_in? }.merge(search_params)
    )
  end

  def search_params
    params.permit(Projects::SearchForm.permitted_attributes)
  end
end
