# frozen_string_literal: true

class Mypage::Fc::Profiles::GeneralsController < Mypage::Fc::BaseController
  def edit
    render layout: 'modal'
  end

  # rubocop:disable Metrics/AbcSize
  # :reek:DuplicateMethodCall
  def update
    form.assign_attributes(update_params)
    if form.save(person)
      if request.xhr? && form.phone_changed?
        # :nocov:
        head :created, location: mypage_fc_phone_confirmation_path
        # :nocov:
      elsif request.xhr?
        # :nocov:
        head :no_content
        # :nocov:
      else
        redirect_to mypage_fc_profile_path, notice: '基本情報を更新しました。'
      end
    else
      render :edit, layout: 'modal', status: :unprocessable_entity
    end
  end
  # rubocop:enable Metrics/AbcSize

  helper_method :form

  private

  # :nocov:
  def fc_user
    @fc_user ||= current_fc_user
  end
  # :nocov:

  # :nocov:
  def account
    @account ||= current_fc_user.account
  end
  # :nocov:

  def person
    @person ||= current_fc_user.person
  end

  def profile
    @profile ||= person.to_sobject.tap { |profile| authorize_profile(profile) }
  end

  def form
    @form ||= Fc::EditProfile::GeneralForm.new_from_sobject_with_user(profile, user: current_fc_user)
  end

  def pundit_params_for(_record)
    params.require(:general)
  end

  def update_params
    permitted_attributes(profile, nil, policy_class: Mypage::Fc::Profiles::GeneralPolicy)
  end

  def authorize_profile(profile)
    authorize profile, nil, policy_class: Mypage::Fc::Profiles::GeneralPolicy
  end
end
