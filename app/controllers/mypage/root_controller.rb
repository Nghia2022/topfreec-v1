# frozen_string_literal: true

class Mypage::RootController < Mypage::ApplicationController
  def index
    redirect_to mypage_fc_root_path and return if current_user.is_a? FcUser
    # :nocov:
    redirect_to mypage_client_root_path and return if current_user.is_a? ClientUser

    redirect_to root_path
    # :nocov:
  end
end
