# frozen_string_literal: true

class Mypage::Fc::Settings::ProjectRequestsController < Mypage::Fc::BaseController
  before_action :authorize_resource

  def edit
    render layout: 'modal'
  end

  def update
    form.assign_attributes(update_params)
    if form.save(current_fc_user.person)
      redirect_to mypage_fc_profile_path, notice: '案件紹介リクエストを更新しました。'
    else
      render :edit, status: :unprocessable_entity, layout: 'modal'
    end
  end

  private

  def authorize_resource
    authorize current_fc_account, policy_class: Mypage::Fc::Settings::ProjectRequestPolicy
  end

  def pundit_params_for(_record)
    params.require(:project_request)
  end

  def update_params
    permitted_attributes(params, nil, policy_class: Mypage::Fc::Settings::ProjectRequestPolicy)
  end

  def form
    @form ||= Fc::Settings::ProjectRequestForm.new_from_contact(current_fc_user.person)
  end

  helper_method :form
end
