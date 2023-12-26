# frozen_string_literal: true

class Admin::ImportsController < Admin::ApplicationController
  def new; end

  def create
    UserImporter.import_from_csv(params[:csv])
    redirect_to :new_admin_import, notice: 'インポートが成功しました'
  rescue StandardError => e
    redirect_to :new_admin_import, alert: "インポートが失敗しました: #{e.message}"
  end
end
