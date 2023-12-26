# frozen_string_literal: true

# disable :reek:TooManyMethods
class Mypage::Client::Direction::ItemCell < ApplicationCell
  include CacheSupport

  property :name
  property :direction_detail

  delegate :approved_by_cl?, to: :model

  # :nocov:
  cache :show do
    [
      model.cache_key_with_version,
      fc_account.cache_key_with_version
    ]
  end
  # :nocov:

  BUTTON_APPEARANCES = {
    'waiting_for_client' => {
      approve: {
        label:   '確認完了',
        visible: true
      },
      reject:  {
        label:   '修正申請',
        visible: true
      }
    },
    'waiting_for_fc' => {
      approve: {
        label:   '確認完了済',
        visible: true
      },
      reject:  {
        label:   '修正申請',
        visible: false
      }
    },
    'completed' => {
      approve: {
        label:   '確認完了済',
        visible: true
      },
      reject:  {
        label:   '修正申請',
        visible: false
      }
    },
    'rejected' => {
      approve: {
        label:   '確認完了',
        visible: true
      },
      reject:  {
        label:   '修正申請',
        visible: true
      }
    }
  }.freeze

  def row
    render
  end

  def buttons
    [approve, reject].compact.join if can_show_buttons?
  end

  def approve
    render if button_visible?(:approve)
  end

  def reject
    render if button_visible?(:reject)
  end

  def fc_name
    fc_account_profile&.full_name
  end

  def approved_date
    I18n.l(model.approved_date_by_cl, format: :date_with_day)
  end

  def button_disabled(flag)
    class_names(disabled: !flag)
  end

  # disable :reek:DuplicateMethodCall
  def button_color(action, flag)
    class_names('btn-theme-02 bs-small':         flag && action == :approve,
                'btn-theme-02-outline bs-small': flag && action == :reject,
                'btn-theme-disabled bs-small':   !flag)
  end

  def button_label(action)
    BUTTON_APPEARANCES[model.status]&.dig(action, :label)
  end

  STATUS_APPEARANCES = {
    'waiting_for_client' => {
      label: '未回答',
      color: 's-fc-01'
    },
    'completed' => {
      label: '回答済み',
      color: 's-fc-08'
    },
    'waiting_for_fc' => {
      label: '回答済み',
      color: 's-fc-08'
    },
    'rejected' => {
      label: '差し戻し',
      color: 'c-l-gray'
    }
  }.freeze

  def status_appearances
    STATUS_APPEARANCES
  end

  def status
    status_appearances[model.status]&.fetch(:label, nil)
  end

  def status_colour
    status_appearances[model.status]&.fetch(:color, nil)
  end

  def can_approve?
    model.may_approve_by_client?(client_user: current_client_user)
  end

  def can_reject?
    model.may_reject_by_client?(client_user: current_client_user)
  end

  private

  def fc_account_profile
    return nil if fc_account.blank?

    ProfileDecorator.decorate(
      cache_sobject(fc_account.cache_key_with_version, expires_in: 1.hour) do
        fc_account.to_sobject
      end
    )
  end

  def fc_account
    model.project.fc_account
  end

  def button_visible?(action)
    BUTTON_APPEARANCES[model.status]&.dig(action, :visible)
  end

  def can_show_buttons?
    model.project.owner?(current_client_user)
  end
end
