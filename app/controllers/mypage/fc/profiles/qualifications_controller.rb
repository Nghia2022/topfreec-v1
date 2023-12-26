# frozen_string_literal: true

class Mypage::Fc::Profiles::QualificationsController < Mypage::Fc::BaseController
  before_action :authorize_resource

  def edit
    render layout: 'modal'
  end

  def update
    form.assign_attributes(update_params)
    if form.save(person)
      redirect_to mypage_fc_profile_path, notice: '資格を登録しました。'
    else
      render :edit, layout: 'modal', status: :unprocessable_entity
    end
  end

  private

  def pundit_params_for(_record)
    params.require(:qualification)
  end

  def update_params
    permitted_attributes(person, policy_class: Mypage::Fc::Profiles::QualificationPolicy)
  end

  def person
    @person ||= current_fc_user.person
  end

  def authorize_resource
    authorize person, nil, policy_class: Mypage::Fc::Profiles::QualificationPolicy
  end

  def form
    @form ||= Fc::EditProfile::QualificationForm.new_from_contact(person)
  end

  helper_method :form
end
