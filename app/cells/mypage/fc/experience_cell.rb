# frozen_string_literal: true

class Mypage::Fc::ExperienceCell < ApplicationCell
  property :name
  property :description
  property :members_num
  property :role
  property :joined
  property :left

  def row
    render
  end

  def freeconsultant?
    model.project?
  end

  def category
    if freeconsultant?
      'フリーコンサルタント.jp'
    else
      'その他'
    end
  end

  def joined
    model.joined_date_text.presence&.then do |val|
      format_period(val)
    end
  end

  def left
    model.left_date_text.presence&.then do |val|
      format_period(val)
    end
  end

  def to_project_detail
    link_to('案件詳細を見る', project_path(model.project), class: 'link-type03 c-red txt-link') if freeconsultant?
  end

  # :nocov:
  def to_edit
    return nil if freeconsultant?

    tag.button '編集',
               class:         'btn btn-type05 bg-red c-white modal-trigger',
               'data-target': 'modal',
               'data-href':   edit_mypage_path
  end
  # :nocov:

  # :nocov:
  def to_destroy
    link_to '削除', mypage_fc_experience_path(model), method: :delete, data: { confirm: 'よろしいですか？' }, class: 'btn btn-type05 bg-gray c-white' unless freeconsultant?
  end
  # :nocov:

  private

  # :nocov:
  def edit_mypage_path
    edit_mypage_fc_experience_path(model)
  end
  # :nocov:
end
