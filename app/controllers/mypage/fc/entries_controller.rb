# frozen_string_literal: true

class Mypage::Fc::EntriesController < Mypage::Fc::BaseController
  before_action :set_main_class
  before_action :set_matchings, only: %i[index]
  before_action :set_matching, only: %i[decline destroy]

  def index
    add_breadcrumb '応募履歴', :mypage_fc_entries_path
  end

  # :nocov:
  def decline
    render layout: 'modal'
  end
  # :nocov:

  def destroy
    form.assign_attributes(update_params)
    if form.decline_entry
      redirect_to mypage_fc_entries_path, notice: '応募を辞退しました。'
    else
      render :decline, status: :unprocessable_entity, layout: 'modal'
    end
  end

  # :nocov:
  def status_info
    render layout: 'modal'
  end
  # :nocov:

  rescue_from AASM::InvalidTransition, with: :invalid_transition

  helper_method :form

  private

  def set_matchings
    authorize Matching, policy_class: Mypage::Fc::EntryPolicy
    @matchings = policy_scope(
      current_fc_user.account.matchings.includes(:project).latest,
      policy_scope_class: Mypage::Fc::EntryPolicy::Scope
    ).decorate
  end

  def set_matching
    @matching = current_user.account.matchings.find(params[:id])
    authorize @matching, policy_class: Mypage::Fc::EntryPolicy
  end

  def form
    @form ||= ActiveType.cast(@matching, Fc::Decline::Matching)
  end

  def update_params
    permitted_attributes(form, Mypage::Fc::EntryPolicy)
  end

  def permitted_attributes(record, policy_class)
    policy = policy_class.new(pundit_user, record)
    pundit_params_for(record).permit(policy.permitted_attributes)
  end

  def pundit_params_for(record)
    params.fetch(Pundit::PolicyFinder.new(record).param_key, {})
  end

  # :nocov:
  def invalid_transition(error)
    case error.event_name
    when :decline
      redirect_to mypage_fc_entries_path, alert: '応募を辞退出来ませんでした。'
    else
      raise error
    end
  end
  # :nocov:

  def set_main_class
    @main_class = 'history-entry'
  end
end
