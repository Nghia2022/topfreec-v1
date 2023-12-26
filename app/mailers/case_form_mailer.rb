# frozen_string_literal: true

class CaseFormMailer < ApplicationMailer
  include ApplicationHelper

  attr_reader :form

  helper_method :form

  before_action :set_form

  def thanks
    build_message('【みらいワークス】お問い合わせ受付', form.email)
  end

  def formatted_description
    text_format(form.description).html_safe # rubocop:disable Rails/OutputSafety
  end
  helper_method :formatted_description

  private

  attr_writer :form

  def set_form
    self.form = Cases::CaseForm.new(params[:form])
  end

  def build_message(subject, to)
    payload = {
      subject:,
      to:
    }
    payload.delete(:to) if delivery_method == :smtp

    mail(payload)
  end
end
