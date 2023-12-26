# frozen_string_literal: true

class Mypage::Fc::Entry::ItemCell < ApplicationCell
  include CompensationFormattable::Current

  property :project
  property :can_decline_immediately?
  property :can_decline_with_reason?

  delegate :project_name, :compensation_min, :compensation_max, to: :project, allow_nil: true

  def row
    render
  end

  def selection_status
    I18n.t(model.selection_status_for_fc, scope: 'enumerize.matching.selection_status_for_fc')
  end

  def application_date
    I18n.l(model.application_date, format: :date_with_day_half)
  end

  def to_project_detail
    # :nocov:
    link_to '案件詳細を見る', project_path(project) if project.present?
    # :nocov:
  end

  def decline_button
    button_class = class_name_for_decline_button
    if can_decline?
      tag.button '辞退手続き', class: button_class, data_type: selection_status, 'data-href': decline_mypage_fc_entry_path(model)
    else
      # :nocov:
      tag.button '辞退手続き', class: button_class
      # :nocov:
    end
  end

  # :nocov:
  def status_colour
    case model.selection_status_for_fc
    when :entry, :proposed
      'c-red s-fc-01'
    when :declined
      'c-l-gray s-fc-gray'
    when :win, :closed
      'c-blue s-fc-08'
    end
  end
  # :nocov:

  # :nocov:
  def modal_data
    {
      target: 'modal'
    }
  end
  # :nocov:

  private

  def can_decline?
    can_decline_immediately? || can_decline_with_reason?
  end

  # :reek:DuplicateMethodCall
  def class_name_for_decline_button
    if can_decline?
      class_names(
        'btn btn-theme-02-outline bs-small jsModalOpen'
      )
    else
      class_names(
        'btn btn-theme-disabled bs-small'
      )
    end
  end
end
