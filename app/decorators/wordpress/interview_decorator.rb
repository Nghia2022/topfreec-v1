# frozen_string_literal: true

class Wordpress::InterviewDecorator < Wordpress::WpPostDecorator
  delegate_all

  def thumbnail
    WordpressImageReplacer.replace(object.thumbnail.__sync&.guid)
  end

  def profile
    postmeta('interview_profile')
  end

  def url
    h.corp_interview_url(object)
  end

  def prev_content
    object.prev_content&.decorate
  end

  def next_content
    object.next_content&.decorate
  end
end
