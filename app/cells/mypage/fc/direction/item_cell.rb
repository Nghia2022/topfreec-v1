# frozen_string_literal: true

class Mypage::Fc::Direction::ItemCell < ApplicationCell
  include CacheSupport

  property :name
  property :direction_detail
  property :can_approve?
  property :can_reject?

  delegate :approved_by_fc?, to: :model

  def row
    render
  end

  def buttons
    [approve, reject].compact.join if can_show_buttons?
  end

  STATUS_APPEARANCES = {
    'waiting_for_fc' => {
      label: '未回答',
      color: 's-fc-01'
    },
    'completed' => {
      label: '回答済み',
      color: 's-fc-08'
    },
    'rejected' => {
      label: '保留',
      color: 'c-l-gray'
    }
  }.freeze

  BUTTON_APPEARANCES = {
    'waiting_for_fc' => {
      approve: {
        label:   '確認完了',
        visible: true
      },
      reject:  {
        label:   '修正申請',
        visible: true
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

  def status_appearances
    STATUS_APPEARANCES
  end

  def status
    status_appearances[model.status]&.fetch(:label, nil)
  end

  def status_colour
    status_appearances[model.status]&.fetch(:color, nil)
  end

  def approved_date
    I18n.l(model.approved_date_by_fc, format: :date_with_day)
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

  # :nocov:
  def modal_data
    {
      target: 'modal'
    }
  end
  # :nocov:

  def can_show_buttons?
    model.project.manager?(current_fc_user)
  end

  def can_approve?
    model.may_approve_by_fc?(fc_user: current_fc_user)
  end

  def can_reject?
    model.may_reject_by_fc?(fc_user: current_fc_user)
  end

  def fc_name
    fc_account_profile&.full_name
  end

  private

  def approve
    render if button_visible?(:approve)
  end

  def reject
    render if button_visible?(:reject)
  end

  def button_visible?(action)
    BUTTON_APPEARANCES[model.status]&.dig(action, :visible)
  end

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
end
