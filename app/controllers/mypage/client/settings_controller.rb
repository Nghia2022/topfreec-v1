# frozen_string_literal: true

class Mypage::Client::SettingsController < Mypage::Client::BaseController
  def index; end

  concerning :Breadcrumbs do
    included do
      add_breadcrumb '設定', :mypage_client_settings_path
    end
  end
end
