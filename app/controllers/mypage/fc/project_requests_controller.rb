# frozen_string_literal: true

class Mypage::Fc::ProjectRequestsController < Mypage::Fc::BaseController
  before_action :authorize_resource

  def edit
    render layout: false
  end

  def update
    form.assign_attributes(update_params)
    if form.save(current_fc_user.person)
      head :ok
    else
      render :edit, layout: false, status: :unprocessable_entity
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
