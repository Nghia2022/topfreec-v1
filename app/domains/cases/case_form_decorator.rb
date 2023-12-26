# frozen_string_literal: true

class Cases::CaseFormDecorator < Draper::Decorator
  delegate_all
  decorates Cases::CaseForm
end
