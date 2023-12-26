# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/case_form/thanks
class CaseFormPreview < ActionMailer::Preview
  def thanks
    form = FactoryBot.attributes_for(:case_form)
    CaseFormMailer.with(form:).thanks
  end
end
