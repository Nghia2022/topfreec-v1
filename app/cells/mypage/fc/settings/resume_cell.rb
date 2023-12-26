# frozen_string_literal: true

class Mypage::Fc::Settings::ResumeCell < ApplicationCell
  def show
    render if render?
  end

  def last_uploaded_at
    time = options.fetch(:last_uploaded_at)
    "アップロード日時：#{I18n.l(time, format: :localized_datetime)}" if time.present?
  end

  def with_notice
    yield(notice) if notice.present?
  end

  private

  def notice
    options.fetch(:notice)
  end

  def render?
    current_user.fc?
  end
end
