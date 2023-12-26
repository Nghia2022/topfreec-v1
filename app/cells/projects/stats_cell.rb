# frozen_string_literal: true

class Projects::StatsCell < ApplicationCell
  def show
    if form.filter?
      render view: :show, layout: 'layout'
    else
      render view: :empty, layout: 'layout'
    end
  end

  private

  alias projects model

  def form
    options.fetch(:form, Projects::SearchForm.new)
  end
end
