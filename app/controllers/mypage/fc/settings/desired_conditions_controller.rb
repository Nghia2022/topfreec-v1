# frozen_string_literal: true

class Mypage::Fc::Settings::DesiredConditionsController < Mypage::Fc::BaseController
  before_action :authorize_resource

  def edit
    render layout: 'modal'
  end

  def update
    form.assign_attributes(update_params)
    if form.save(current_fc_user.person)
      redirect_to mypage_fc_profile_path, notice: '資格を登録しました。'
    else
      render :edit, status: :unprocessable_entity, layout: 'modal'
    end
  end

  private

  def authorize_resource
    authorize current_fc_account, policy_class: Mypage::Fc::Settings::DesiredConditionPolicy
  end

  def pundit_params_for(_record)
    params.require(:desired_condition)
  end

  def update_params
    permitted_attributes(params, nil, policy_class: Mypage::Fc::Settings::DesiredConditionPolicy)
  end

  def form
    @form ||= Fc::Settings::DesiredConditionForm.new_from_contact(current_fc_user.person)
  end

  helper_method :form
end
