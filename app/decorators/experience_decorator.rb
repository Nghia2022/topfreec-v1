# frozen_string_literal: true

class ExperienceDecorator < Draper::Decorator
  delegate_all

  decorates_association :project

  def description
    object.details_self__c.presence || object.detail_mws__c.presence || ''
  end

  def members_num
    object.member_amount__c
  end

  def role
    object.position__c
  end

  def joined_date_text
    I18n.ln(object.start_date__c, format: :default) # FIXME: 日付部は表示しない？
  end

  def left_date_text
    I18n.ln(object.end_date__c, format: :default) # FIXME: 日付部は表示しない？
  end

  class << self
    def collection_decorator_class
      PaginatingDecorator
    end
  end
end
