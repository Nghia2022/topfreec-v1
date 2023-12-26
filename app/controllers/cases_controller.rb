# frozen_string_literal: true

class CasesController < ApplicationController
  def new
    form
  end

  def create
    prepare_form
    if form.persisted?
      CaseFormMailer.with(form: form.serialize).thanks.deliver_later
      redirect_to thanks_cases_path, notice: 'お問い合わせを登録しました。'
    else
      render :new
    end
  end

  def thanks; end

  private

  def prepare_form
    form.assign_attributes(create_params)
    if params[:back]
      form.reset_confirming
    else
      form.save
    end
  end

  def create_params
    permitted_attributes(form, nil, policy_class: CasePolicy)
  end

  def form
    @form ||= Cases::CaseForm.new.decorate
  end

  helper_method :form

  concerning :Breadcrumbs do
    protected

    def build_breadcrumbs(_options)
      add_breadcrumb 'TOP', :root_path
      add_breadcrumb 'お問い合わせ', new_case_path
    end
  end
end
