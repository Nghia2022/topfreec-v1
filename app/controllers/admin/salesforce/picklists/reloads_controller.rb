# frozen_string_literal: true

class Admin::Salesforce::Picklists::ReloadsController < Admin::ApplicationController
  def show; end

  def update
    form.assign_attributes(permitted_attributes)
    if form.valid?
      Salesforce::Picklists::ReloadJob.perform_later(sobject_name: form.sobject_name)

      redirect_to admin_salesforce_picklists_reload_path, notice: '選択リストマスタの更新を開始しました'
    else
      redirect_to admin_salesforce_picklists_reload_path, alert: form.errors.full_messages.join("\n")
    end
  end

  private

  def form
    @form ||= Admin::Salesforce::Picklists::ReloadForm.new
  end

  def permitted_attributes
    params.require(:reload).permit(:sobject_name)
  end

  helper_method :form
end
