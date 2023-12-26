# frozen_string_literal: true

class Mypage::Fc::Phone::ConfirmationsController < Mypage::Fc::BaseController
  layout 'welcome'

  def show; end

  def create
    if form.save
      redirect_to mypage_fc_settings_path
    else
      # set_flash_message :alert, :attempt_failed, now: true
      render :show
    end
  end

  def update
    fc_user.send_new_otp
    redirect_to mypage_fc_phone_confirmation_path
  end

  private

  def fc_user
    current_fc_user.decorate
  end

  def create_params
    params.permit(:code)
  end

  helper_method :fc_user

  def form
    @form ||= Fc::EditProfile::PhoneConfirmationForm.new(create_params, user: current_fc_user)
  end
end
