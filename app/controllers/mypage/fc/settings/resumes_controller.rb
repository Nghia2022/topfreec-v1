# frozen_string_literal: true

class Mypage::Fc::Settings::ResumesController < Mypage::Fc::BaseController
  def new
    render layout: 'modal'
  end

  def create
    form.assign_attributes(create_params)
    if form.save(account.sfid)
      flash[:notice] = 'レジュメをアップロードしました'
      head :created, location: mypage_fc_settings_path
    else
      render :new, layout: 'modal', status: :unprocessable_entity
    end
  end

  private

  def fc_user
    @fc_user ||= current_fc_user
  end

  def account
    @account ||= fc_user.account
  end

  def form
    @form ||= Fc::EditProfile::ResumeForm.new
  end
  helper_method :form

  def create_params
    params.fetch(:resume, {}).permit(form.class.permitted_attributes)
  end
end
