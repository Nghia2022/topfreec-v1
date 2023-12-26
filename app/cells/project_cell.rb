# frozen_string_literal: true

class ProjectCell < ApplicationCell
  include CloudinaryHelper
  include CategoryImages::ItemHelpers
  include CompensationFormattable
  include FormatMixins

  property :id
  property :project_id
  property :project_name
  property :compensation_min
  property :compensation_max
  property :compensation_note
  property :intern?
  property :period
  property :operating_rate_min
  property :operating_rate_max
  property :operating_rate_note
  property :recruiting
  property :operator_picture_flag
  property :experience_categories
  property :contract_type
  property :work_location
  property :work_options
  property :place_note
  property :work_section
  property :work_environment
  property :participation_period
  property :type
  property :operator_name
  property :period_from
  property :period_to

  delegate :dispatch_contract?, to: :type, allow_nil: true

  def initialize(...)
    super
    extend CompensationFormattable::V2022
  end

  def featured
    render
  end

  def recommended
    render
  end

  def card
    render
  end

  def detail
    render
  end

  # disable :reek:DuplicateMethodCall
  def entry_button
    if entry_disabled?
      disabled_entry_button
    elsif fc_user_signed_in?
      tag.button 'この案件に応募する', id: 'btn-entry', class: class_names(entry_button_class_names, 'btn-theme-04 jsModalOpen'), 'data-href': new_project_entry_path(model)
    else
      link_to 'この案件に応募する', new_fc_user_session_path, id: 'btn-entry', class: class_names(entry_button_class_names, 'btn-theme-disabled')
    end
  end

  def entry_button_for_index
    if entry_disabled?
      disabled_entry_button
    elsif fc_user_signed_in?
      tag.button '今すぐ応募する', class: class_names(entry_button_class_names, 'btn-theme-02-outline bs-normal jsModalOpen'), 'data-href': new_project_entry_path(model)
    else
      link_to '今すぐ応募する', new_fc_user_session_path, class: class_names(entry_button_class_names, 'btn-theme-02-outline')
    end
  end

  def human_resources
    text_format(model.human_resources)
  end

  def human_resources_sub
    @human_resources_sub ||= text_format(model.human_resources_sub)
  end

  def job_outline
    text_format(model.job_outline)
  end

  def description
    text_format(model.description)
  end

  def background
    text_format(model.background)
  end

  def operator_comment
    text_format(model.operator_comment)
  end

  # :nocov:
  def modal_data
    {
      target: 'modal'
    }
  end
  # :nocov:

  def new?
    model.created_at > Project.new_arrival_at
  end

  def experience_categories_text
    experience_categories.join(', ')
  end

  def client_category_name
    model.client_category_name.presence || '非公開'
  end

  def operating_rates
    @operating_rates ||= join_wave_dash(operating_rate_array, '％')
  end

  def operator_image
    url = model.operator_image_transforms.user_profile
    if operator_picture_flag && URI::DEFAULT_PARSER.make_regexp.match?(url)
      url
    else
      cl_image_path('projects/operators/default.png', transformation: 'user_profile')
    end
  end

  def participation_period?
    return false if model.entry_closed?
    return false if period_to && period_to < today

    true
  end

  def participation_period_date # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    if period_from && period_from < today
      if period_from.all_month.cover?(today)
        "#{period_from_text} 〜"
      else
        'ご提案時調整'
      end
    elsif period_from && !period_to
      "#{period_from_text} 〜 個別調整"
    elsif !period_from && period_to
      "ご提案時調整 〜 #{period_to_text}"
    elsif period_from && period_to
      "#{period_from_text} 〜 #{period_to_text}"
    end
  end

  def participation_period_duration
    return if period_from && period_from < today

    participation_period
  end

  private

  def operating_rate_array
    [operating_rate_min, operating_rate_max].map(&:presence).compact.uniq
  end

  def entry_exists?
    options.fetch(:entry_exists, false)
  end

  def entry_stopped?
    options.fetch(:entry_stopped, false)
  end

  def disabled_button_tag(label, button_class)
    tag.button label, class: class_names(button_class, 'btn-theme-disabled'), disabled: true
  end

  def format_period_date(date)
    I18n.ln(date, format: :without_date)
  end

  def period_from_text
    format_period_date(period_from)
  end

  def period_to_text
    format_period_date(period_to)
  end

  def today
    Date.current
  end

  def published_at
    I18n.ln(model.published_at, format: :date_by_period)
  end

  def entry_disabled?
    entry_stopped? || entry_exists? || current_user&.fc_company? || model.entry_closed?
  end

  def disabled_entry_button
    label = if entry_stopped?
              '受付終了'
            elsif entry_exists?
              '応募済み'
            elsif current_user&.fc_company? || model.entry_closed? # rubocop:disable Lint/DuplicateBranch
              '受付終了'
            end
    disabled_button_tag(label, entry_button_class_names)
  end

  def entry_button_class_names
    class_names('btn bs-long')
  end
end
