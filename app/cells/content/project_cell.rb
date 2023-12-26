# frozen_string_literal: true

class Content::ProjectCell < ApplicationCell
  property :project_name

  def show
    render
  end

  private

  def project_date
    I18n.ln(model.created_at, format: :date_with_day_half)
  end
end
