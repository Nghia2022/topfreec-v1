# frozen_string_literal: true

class Content::InterviewCell < ApplicationCell
  property :post_title
  property :facebook_share_url
  property :twitter_share_url
  property :hatena_share_url
  property :thumbnail
  property :prev_content
  property :next_content

  delegate :post_title, :thumbnail, :url, to: :prev_content, prefix: true, allow_nil: true
  delegate :post_title, :thumbnail, :url, to: :next_content, prefix: true, allow_nil: true

  def show
    render
  end

  def detail
    render
  end

  def prev_link
    render
  end

  def next_link
    render
  end

  private

  def post_date
    I18n.ln(model.post_date, format: :date_with_day_half)
  end

  def profile
    auto_paragraph(sanitized_profile)
  end

  def post_content
    auto_paragraph(model.post_content)
  end

  def sanitized_profile
    sanitize(model.profile, tags: %w[a], attributes: %w[href target rel])
  end

  def prev_content_class
    'invisible' if prev_content.blank?
  end

  def next_content_class
    'invisible' if next_content.blank?
  end

  def prev_content_post_date
    I18n.ln(prev_content.post_date, format: :date_by_period) if prev_content.present?
  end

  def next_content_post_date
    I18n.ln(next_content.post_date, format: :date_by_period) if next_content.present?
  end
end
