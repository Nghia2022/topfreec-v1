# frozen_string_literal: true

class Mypage::Client::BaseController < Mypage::ApplicationController
  before_action :authenticate_client_user!

  include TrackFieldsUpdatable

  add_breadcrumb 'マイページ', :mypage_root_path

  alias pundit_user current_client_user
end
