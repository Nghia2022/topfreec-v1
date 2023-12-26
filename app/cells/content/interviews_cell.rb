# frozen_string_literal: true

class Content::InterviewsCell < ApplicationCell
  def show
    cell(Content::InterviewCell, collection: model.decorate).call(:show)
  end
end
