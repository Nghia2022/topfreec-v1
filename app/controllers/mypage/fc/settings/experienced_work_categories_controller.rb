# frozen_string_literal: true

class Mypage::Fc::Settings::ExperiencedWorkCategoriesController < ApplicationController
  before_action :authorize_resource

  def edit
    render layout: 'modal'
  end

  def update
    form.assign_attributes(update_params)
    if form.save(current_fc_user.person)
      redirect_to mypage_fc_profile_path, notice: '得意領域を登録しました。'
    else
      render :edit, status: :unprocessable_entity, layout: 'modal'
    end
  end

  private

  def authorize_resource
    authorize current_fc_account, policy_class: Mypage::Fc::Settings::ExperiencedWorkCategoryPolicy
  end

  def pundit_params_for(_record)
    params.require(:experienced_work_categories)
  end

  def update_params
    permitted_attributes(params, nil, policy_class: Mypage::Fc::Settings::ExperiencedWorkCategoryPolicy)
  end

  def form
    @form ||= Fc::Settings::ExperiencedWorkCategoryForm.new_from_contact(current_fc_user.person)
  end

  helper_method :form
end
